# encoding: utf-8

class History < Resource
  include Mongoid::Document
  include Haikanko::Helper
  field :node_type, type: String, default: 'agent'
  field :host, type: String
  field :deployed_at, type: Time

  class << self
    def agent_deployed!(hosts)
      set_deployed_at("agent", hosts, Time.now)
      report_time do
        Feature.on_hostnames(hosts).each do |feature|
          feature.set(:all_agent_deployed, feature.hostnames.all? {|host| feature.agent_deployed?(host) })
        end
      end
    end

    def worker_deployed!(hostports)
      set_deployed_at("worker", hostports, Time.now)
      report_time do
        Feature.all.each do |feature|
          feature.set(:all_worker_deployed, FluentdConfig.workers.all? {|hostport| feature.worker_deployed?(hostport) })
        end
      end
    end

    def agent_removed!(hosts)
      set_deployed_at("agent", hosts, nil)
      report_time do
        Feature.on_hostnames(hosts).each do |feature|
          feature.set(:all_agent_deployed, false)
        end
      end
    end

    def worker_removed!(hostports)
      set_deployed_at("worker", hostports, nil)
      report_time do
        Feature.all.each do |feature|
          feature.set(:all_worker_deployed, false)
        end
      end
    end

    private

    def set_deployed_at(node_type, hosts, time)
      Array.wrap(hosts).each do |host|
        params = { node_type: node_type, host: host }
        hist = find_by(params) || new.tap {|e| e.node_type = node_type; e.host = host }
        hist.deployed_at = time
        hist.save!
      end
    end
  end
end
