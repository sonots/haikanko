# encoding: utf-8

class Irc < GroupResource
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::Paranoia
  has_and_belongs_to_many :features, class_name: 'Feature'

  field :label, type: String, default: 'arbitrary_label'
  field :channel, type: String
  field :staff, type: String

  index({label: 1}, {unique: true})
  validates_presence_of :label
  validates_uniqueness_of :label
  before_save :notify_updated

  def self.fabricate!
    [
      :irc_one,
      :irc_two,
      :irc_three,
    ].each { |irc| Fabricate(irc) }
  end
end
