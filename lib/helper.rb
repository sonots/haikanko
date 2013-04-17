FluentdConfig.workers = (FluentdConfig.primary_workers || []) + (FluentdConfig.secondary_workers || []).uniq.sort

module Haikanko
  module Helper
    def self.included(base)
      base.extend Helper
    end

    def report_time(&blk)
      t = Time.now
      output = yield
      $logger.debug "Elapsed time: %.2f seconds at %s" % [(Time.now - t).to_f, caller()[0]]
      output
    end
  end
end
