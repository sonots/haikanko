# encoding: utf-8

class Role < GroupResource
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::Paranoia
  has_and_belongs_to_many :features, class_name: 'Feature'

  field :label, type: String, default: 'arbitrary_label'
  field :hosts, type: Array

  index({label: 1}, {unique: true})
  validates_presence_of :label
  validates_uniqueness_of :label
  before_save :notify_updated

  def self.on_hosts(hosts)
    Array.wrap(hosts).map do |host|
      self.where(hosts: host).map(&:label)
    end.flatten.uniq.compact
  end

  def self.hosts(roles)
    Array.wrap(roles).map do |role|
      Role.find_by(label: role).try(:hosts)
    end.flatten.uniq.compact
  end

  def self.fabricate!
    [
      :role_one,
      :role_two,
      :role_three,
    ].each { |role| Fabricate(role) }
  end
end
