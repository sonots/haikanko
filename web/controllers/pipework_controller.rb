# encoding: utf-8

module Web
  class PipeworkController < ResourceController
    set :views, File.join(File.dirname(__FILE__), '..', 'views', 'pipework')
    set :layout, './layout'
    mime_type :text, 'text/plain'

    before do
      set_configurer
      set_commander
    end

    get '/' do
    end

    error 404 do
      'Not Found'
    end

    error 400 do
      'Bad Request'
    end

    get '/agent.conf' do
      config_template { return @configurer.agent(params['host']) }
    end

    get '/worker.conf' do
      config_template { return @configurer.worker(params['hostport']) }
    end

    # deploy @todo: instroduce asyncrhronous processing
    post '/agent.conf' do
      # parms['host']
      deploy_template { @command, @result = @commander.agent_deploy(params) }
    end

    post '/worker.conf' do
      # parms['hostport']
      deploy_template { @command, @result = @commander.worker_deploy(params) }
    end

    post '/all' do
      # parms['label']
      deploy_template { @command, @result = @commander.all_deploy(params) }
    end

    post '/all_agent' do
      # parms['label']
      deploy_template { @command, @result = @commander.agent_deploy(params) }
    end

    post '/all_worker' do
      # parms['label']
      deploy_template { @command, @result = @commander.worker_deploy(params) }
    end

    private

    def config_template
      content_type :text
      begin
        yield if block_given?
      rescue ::Pipework::NotFound => e
        return 400
      end
    end

    def deploy_template
      begin
        yield if block_given?
        herb :result
      rescue ::Pipework::NotFound => e
        return 400
      end
    end

    def set_commander
      @commander = ::Pipework::Commander.new
    end

    def set_configurer
      @configurer = ::Pipework::Configurer.new
    end
  end
end
