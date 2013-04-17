# encoding: utf-8

class Email < GroupResource
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::Paranoia
  has_and_belongs_to_many :features, class_name: 'Feature'

  field :label, type: String, default: 'arbitrary_label'
  field :email_to, type: String
  # field :message, type: String

  index({label: 1}, {unique: true})
  validates_presence_of :label
  validates_uniqueness_of :label
  before_save :notify_updated

  def self.fabricate!
    [
      :email_one,
      :email_two,
      :email_three,
    ].each { |email| Fabricate(email) }
  end
end
