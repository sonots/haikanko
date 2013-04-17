# encoding: utf-8

if current_namespace == :agent
  agent_opt_parse
  agent_init_variables
end

def agent_opt_parse
  hostnames = []
  if ENV['LABEL']
    hostnames = Feature.hostnames(ENV['LABEL'].split(","))
    $stderr.puts 'LABEL does not exist' and exit unless hostnames.present?
  elsif ENV['ROLE']
    hostnames = (ENV['ROLE'] == 'all' ? Feature.all_hostnames : Role.hosts(ENV['ROLE'].split(",")))
    $stderr.puts 'ROLE does not exist' and exit unless hostnames.present?
  elsif ENV['HOST']
    hostnames = ENV['HOST'].split(",")
  else
    $stderr.puts "  HOST=host1,host2 mina agent:{task} -v"
    $stderr.puts "  ROLE=role1,role2 mina agent:{task} -v"
    $stderr.puts "  LABEL=label1,label2 mina agent:{task} -v"
    exit
  end
  set :domains, hostnames
  set :domain, domains.shuffle.first
end

def agent_init_variables
  set :conf_to, "/etc/fluent-agent-lite.conf"
  set :log_to, "/var/log/fluent-agent-lite/fluent-agent.log"
end

%w[update deploy remove restart start stop status force_stop].each do |_task|
  desc "#{_task.capitalize} agent"
  task :"#{_task}" do
    domains.each do |domain|
      invoke_block(domain) { send("agent_#{_task}") }
    end
  end
end

desc "tail -f log file"
task :log do
  queue! "tail -n 100 -f #{log_to}"
end

desc "Show the deployed conf file"
task :conf do
  queue! "less /etc/fluent-agent-lite.conf"
end

def agent_update
  remote_file(conf_to) { ::Pipework::Configurer.new.agent(domain) }
end

def agent_deploy
  yum_haikanko_install("fluent-agent-lite")
  queue! %[sudo mkdir -p $(dirname #{log_to})] # log directory
  agent_update

  agent_restart

  run!
  History.agent_deployed!(domain) unless simulate_mode?
end

def agent_remove
  agent_stop

  yum_haikanko_remove("fluent-agent-lite")

  run!
  History.agent_removed!(domain) unless simulate_mode?
end

def agent_restart
  queue! "sudo /etc/init.d/fluent-agent-lite restart"
end

def agent_start
  queue! "sudo /etc/init.d/fluent-agent-lite start"
end

def agent_stop
  queue! "sudo /etc/init.d/fluent-agent-lite stop"
end

def agent_force_stop
  queue! "ps aux | grep fluent-agent-lite | grep -v grep | awk '{print $2}' | xargs sudo kill -9"
  queue! "sudo /etc/init.d/fluent-agent-lite stop"
end

def agent_status
  queue! "sudo /etc/init.d/fluent-agent-lite status"
end
