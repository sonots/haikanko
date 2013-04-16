# encoding: utf-8

class Notifier < Feature
  field :label, type: String, default: 'syslog warn app_name'
  field :regexp, type: String, default: 'warn'
  field :exclude, type: String
  field :count_interval, type: Integer, default: 300
  field :threshold, type: Integer, default: 1
  # field :ignore_case, type: Boolean

  validate :validates_regexp
  validate :validates_exclude 

  def self.on_roles(roles)
    super(roles).select {|e| e._type == "Notifier" }
  end

  def deployable?
    regexp.present? and (ircs.present? || emails.present?) and super
  end

  # validation
  def validates_regexp
    begin
      Regexp.compile(regexp)
    rescue => e
      errors.add(:regexp, "is invalid")
    end
  end

  def validates_exclude
    begin
      Regexp.compile(exclude) if exclude
    rescue => e
      errors.add(:exclude, "is invalid")
    end
  end
end
