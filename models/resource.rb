# encoding: utf-8

class Resource
  def self.readonly?
    false
  end

  def new?
    created_at.nil?
  end

  def error?
    ! valid?
  end

  def duplicate(params = {})
    attributes = self.attributes.except("_id")
    attributes.merge!(params)
    if attributes["label"] and self.class.find_by(label: attributes["label"])
      attributes["label"] = "Copy of #{label}"
    end
    self.class.create(attributes)
  end

  def enabled?
    return true unless respond_to?(:disabled_at)
    disabled_at.nil?
  end

  def disabled?
    ! enabled?
  end

  def disable!
    return unless respond_to?(:disabled_at)
    self.disabled_at = Time.now
    self.timeless.save!
  end

  def enable!
    return unless respond_to?(:disabled_at)
    self.disabled_at = nil
    self.save!
  end

  # Use this when save! failed. This is actually for view (to display id, etc with the same code with when succeeds)
  def on_errors(id)
    self.id = id
    self.created_at = Time.now
    self
  end

  def self.finds(labels)
    Array.wrap(labels).map {|l| find_by(label: l) }.compact
  end
end
