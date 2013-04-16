# encoding: utf-8

class Feature < Resource
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::Paranoia
  include ActiveModel::Translation

  field :label, type: String, default: 'syslog warn app_name'
  has_and_belongs_to_many :roles, class_name: 'Role'
  has_and_belongs_to_many :hosts, class_name: 'Host'
  field :log_path, type: String, default: '/var/log/syslog'

  has_and_belongs_to_many :ircs, class_name: 'Irc'
  field :email_from, type: String
  has_and_belongs_to_many :emails, class_name: 'Email'

  field :disabled_at, type: Time
  field :deployed_at, type: Time
  field :agent_updated_at, type: Time, default: Time.now # special field for agent_deployed?
  field :deployable, type: Boolean, default: false
  field :all_agent_deployed, type: Boolean, default: false
  field :all_worker_deployed, type: Boolean, default: false

  index({label: 1}, {unique: true})
  validates_presence_of :label
  validates_uniqueness_of :label
  validates_presence_of :log_path
  before_save :update_deployable
  before_save :update_all_agent_deployed
  before_save :update_all_worker_deployed
  after_save Proc.new { self.hosts.each(&:save) }

  scope :enabled, where(:disabled_at => nil)

  def agent_tag
    label.gsub(/\s/, '_').downcase
  end

  def notifier?
    self._type == "Notifier"
  end

  def visualizer?
    self._type == "Visualizer"
  end

  # okay to deploy? (enough configuration)
  def update_deployable
    self.deployable = log_path.present? and (roles.present? or hosts.present?)
    true
  end

  # updating feature settings require re-deploying agents
  def update_all_agent_deployed
    stored = self.class.find(id)
    if stored.nil? || label != stored.label || log_path != stored.log_path
      # only label and log_path effects agent.conf
      self.agent_updated_at = updated_at if updated_at
      self.all_agent_deployed = false
    end
    true
  end

  # updating feature settings require re-deploying workers
  def update_all_worker_deployed
    self.all_worker_deployed = false
    true
  end

  ### helpers
  def hostnames
    (self.roles.map {|role| role.hosts } + self.hosts.map(&:label)).flatten.uniq.compact
  end

  # Get target roles from feature labels
  def self.roles(labels)
    Array.wrap(labels).map do |label|
      self.find_by(label: label).try(:roles)
    end.flatten.uniq.compact
  end

  # Get target hosts from feature labels
  def self.hostnames(labels)
    Array.wrap(labels).map do |label|
      self.where(label: label).first.try(:hostnames)
    end.flatten.uniq.compact
  end

  # Get all target hosts
  def self.all_hostnames
    roles = Feature.all.map(&:roles).flatten.map(&:label).uniq.compact
    hosts = Feature.all.map(&:hosts).flatten.map(&:label).uniq.compact
    hosts = (hosts + Role.hosts(roles)).uniq.compact
  end

  # Get features whose targets are specified roles
  def self.on_roles(roles)
    Array.wrap(roles).map do |role|
      Role.find_by(label: role).try(:features).try(:to_a)
    end.flatten.compact
  end

  # Get features whose targets are specified hosts
  def self.on_hostnames(hostnames)
    role_features = self.on_roles Role.on_hosts(hostnames)
    host_features = Array.wrap(hostnames).map do |host|
      Host.find_by(label: host).try(:features).try(:to_a)
    end
    (role_features + host_features).flatten.uniq.compact
  end

  ### history helpers
  def agent_deployed?(hostname)
    hist = History.find_by(host: hostname, node_type: "agent")
    if enabled?
      return false if hist.nil? or hist.deployed_at.nil?
      hist.deployed_at >= self.agent_updated_at if self.agent_updated_at
    else
      return true if hist.nil? or hist.deployed_at.nil?
      hist.deployed_at >= self.disabled_at if self.disabled_at
    end
  end

  def worker_deployed?(hostname)
    hist = History.find_by(host: hostname, node_type: "worker")
    if enabled?
      return false if hist.nil? or hist.deployed_at.nil?
      hist.deployed_at >= self.updated_at if self.updated_at
    else
      return true if hist.nil? or hist.deployed_at.nil?
      hist.deployed_at >= self.disabled_at if self.disabled_at
    end
  end

  def deployable?
    deployable
  end

  def all_agent_deployed?
    all_agent_deployed
  end

  def all_worker_deployed?
    all_worker_deployed
  end

  def all_deployed?
    all_agent_deployed? and all_worker_deployed?
  end
end
