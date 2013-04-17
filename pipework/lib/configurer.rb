# encoding: utf-8
require 'tilt'

module Pipework
  class NotFound < StandardError; end
end

module Pipework
  class Configurer
    def agent(hostname)
      raise NotFound if hostname.nil?
      features = Feature.on_hostnames(hostname).select {|f| f.enabled? and f.deployable? }
      herb "agent", locals: {
        features: features,
        primary_servers: FluentdConfig.primary_workers,
        secondary_servers: FluentdConfig.secondary_workers,
      }
    end

    def worker(hostport = nil)
      raise NotFound if hostport.nil?
      bind = hostport.split(":")[0]
      port = hostport.split(":")[1]
      herb "worker", locals: {
        bind: bind,
        port: port,
        notifiers: Notifier.all,
        visualizers: Visualizer.all,
      }
    end

    private

    def herb(name, options = {})
      path = File.join(File.dirname(__FILE__), "../templates/#{name}.erb")
      Tilt.new(path).render(self, options[:locals])
    end
  end
end
