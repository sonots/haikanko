# encoding: utf-8

class GroupResource < Resource
  def notify_updated
    features.each {|f| f.updated_at = updated_at; f.save! } if !chained_update?
  end

  def chained_update?
    stored = self.class.find(id)
    stored.present? and (stored.feature_ids <=> self.feature_ids) != 0
  end
end
