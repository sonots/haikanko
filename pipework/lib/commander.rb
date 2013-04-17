# encoding: utf-8
require 'dropkick'

module Pipework
  class Commander
    %w(deploy remove update restart start stop status).each do |action|
      define_method("agent_#{action}") do |params|
        command = mina_command("agent", action, params)
        result = execute(command)
        [command, result]
      end

      define_method("worker_#{action}") do |params|
        command = mina_command("worker", action, params)
        result = execute(command)
        [command, result]
      end

      define_method("all_#{action}") do |params|
        feature = Feature.find_by(label: params['label']) if params['label']
        raise NotFound unless feature
        command = mina_command("worker", action, params) + ";"
        command += mina_command("agent", action, params)
        result = execute(command)
        [command, result]
      end
    end

    private
    def execute(command)
      result = Dropkick::Command.secure_exec(command)
    end

    def mina_command(type, action, params)
      "cd #{APP_ROOT} && #{sudo} #{mina_env(params)} bundle exec mina #{type}:#{action} #{mina_params(params)}"
    end

    def sudo
      "sudo -u #{ENV['USER']} RACK_ENV=#{ENV['RACK_ENV']}"
    end

    def mina_env(params)
      if params['label']
        "LABEL='#{params['label']}'"
      elsif params['role']
        "ROLE='#{params['role']}'"
      elsif params['host']
        "HOST='#{Array.wrap(params['host']).join(',')}'"
      elsif params['hostport']
        "HOSTPORT='#{Array.wrap(params['hostport']).join(',')}'"
      end
    end

    def mina_params(params)
      params['exec'].present? ? '-v' : '-S'
    end
  end
end
