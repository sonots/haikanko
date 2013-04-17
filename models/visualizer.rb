# encoding: utf-8

class Visualizer < Feature
  field :label, type: String, default: 'accesslog app_name'
  field :format, type: String, default: '/^\[(?<time>[^\]]*)\] (?<pid>[^\t]*)\t(?<reqtime>[^\t]*)\t(?<device_id>[^\t]*)\t(?<app_id>[^\t]*)\t(?<viewer_id>[^\t]*)\t(?<owner_id>[^\t]*)\t(?<status>[^\t]*)\t(?<method>[^\t]*)\t(?<uri>[^\t]*)$/'
  field :graphs, type: Hash, default: { "reqtime" => "", "status" => "" }
  field :warn_threshold, type: Hash, default: { "reqtime" => 1, "status" => 1 }
  field :crit_threshold, type: Hash, default: { "reqtime" => 100, "status" => 100 }

  validate :validates_format

  def self.on_roles(roles)
    super(roles).select {|e| e._type == "Visualizer" }
  end

  def deployable?
    format.present? and (status? or reqtime?) and super
  end

  def notifiable?
    deployable? and (ircs.present? or emails.present?)
  end

  def status?
    graphs.has_key?('status')
  end

  def reqtime?
    graphs.has_key?('reqtime')
  end

  # validation
  def validates_format
    begin
      Regexp.compile(format[1..-2])
    rescue => e
      errors.add(:format, "is invalid regexp")
    end
  end
end
