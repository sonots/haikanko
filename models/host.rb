# encoding: utf-8

class Host < Resource
  include Mongoid::Document
  include Mongoid::Timestamps
  has_and_belongs_to_many :features, class_name: 'Feature'

  field :label, type: String

  index({label: 1}, {unique: true})
  validates_presence_of :label
  validates_uniqueness_of :label

  def self.makes(hosts)
    Array.wrap(hosts).reject(&:empty?).map {|h| Host.where(label: h).first || Host.new(label: h) }
  end
end
