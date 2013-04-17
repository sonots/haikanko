# encoding: utf-8

module Web
  class RequestLogger

    def initialize(app, logger)
      @app = app
      @logger = logger
    end

    def call(env)
      began_at = Time.now
      begin
        status, header, body = @app.call(env)
      rescue => e
        error = e
      end
      http_method = env['REQUEST_METHOD']
      url = File.join(env['REQUEST_PATH'] || '', env['PATH_INFO'] || '')
      params = (env['rack.request.query_hash'] || {}).merge(env['rack.request.form_hash'] || {})
      if error
        logger.error(dump_error(error))
        ::NewRelic::Agent.agent.error_collector.notice_error(error, uri: url, request_params: params) if defined?(::NewRelic::Agent)
        [500, {'Content-Type' => 'application/json'}, ['']]
      else
        logger.info %Q|#{http_method} #{url}, params: #{params},#{status != 200 ? " response: #{body}" : ''} #{status} - #{"%0.3f" % (Time.now - began_at)}|
        [status, header, body]
      end
    end

    private

    def logger
      @logger
    end

    def dump_error(e)
      "#{e.class}: #{e.message}\n".tap { |s| s << e.backtrace.map { |l| "\t#{l}" }.join("\n") }
    end

  end
end
