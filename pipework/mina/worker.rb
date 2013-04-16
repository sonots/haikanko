# encoding: utf-8

if current_namespace == :worker
  worker_opt_parse
end

def worker_opt_parse
  hostports = []
  if ENV['HOSTPORT']
    hostports = ENV['HOSTPORT'].split(",")
  else
    hostports = FluentdConfig.workers
  end
  set :hostports, hostports
  set :domain, hostports.map {|hostport| hostport.split(":")[0] }
end

def worker_init_variables(hostport)
  set :domain, hostport.split(":")[0]
  set :daemon_name, "fluentd_#{hostport}"
  set :fluent_bin, %[/usr/lib$(uname -i | grep x86_64 > /dev/null && echo 64)/fluent/ruby/bin]
  set :fluentd_to, '$HOME/fluentd/server'
  set :daemontools_to, "$HOME/fluentd/#{daemon_name}"
  set :conf_to, "#{daemontools_to}/fluentd.conf"
  set :log_to, "/var/log/fluentd/#{daemon_name}/fluentd.log"
end

%w[deploy remove update restart start stop status].each do |_task|
  desc "#{_task.capitalize} worker"
  task :"#{_task}" do
    hostports.each do |hostport|
      domain = hostport.split(":")[0]
      invoke_block(domain) { send("worker_#{_task}", hostport) }
    end
  end
end

desc "tail -f log file"
task :log do
  queue! %[tail -n 100 -f #{log_to}]
end

desc "Show the deployed conf file"
task :conf do
  queue! %[less #{conf_to}]
end

desc "tail -f the flowcounter log"
task :flowcount do
  queue! %[tail -n 100 -f $(ls /var/log/td-agent/flowcounter* | tail -n 1)]
end

def worker_update(hostport)
  worker_init_variables(hostport)
  remote_file(conf_to) { ::Pipework::Configurer.new.worker(hostport) }
end

def worker_deploy(hostport)
  worker_init_variables(hostport)
  remove_daemontools(daemon_name)

  yum_haikanko_install("td-agent")
  queue! %[sudo mkdir -p $(dirname #{log_to})]

  # install fluentd plugins by bundler
  remote_directory(fluentd_to, File.expand_path('server', fluentd_dir))
  fluent_bundle(fluentd_to)

  remote_directory(daemontools_to, File.expand_path('daemontools', fluentd_dir))
  worker_update(hostport)
  worker_setup_daemontools

  run!
  History.worker_deployed!(hostport) unless simulate_mode?
end

def worker_setup_daemontools
  queue! %[sudo mkdir -p "/service"]
  queue! %[sudo ln -snf "#{daemontools_to}" "/service/#{daemon_name}"]
  queue! %[whoami | sudo tee "/service/#{daemon_name}/env/USER" > /dev/null]
  queue! %[echo "#{log_to}" | sudo tee "/service/#{daemon_name}/env/LOG" > /dev/null]
  queue! %[echo "#{conf_to}" | sudo tee "/service/#{daemon_name}/env/CONF" > /dev/null]
  queue! %[echo "#{fluentd_to}" | sudo tee "/service/#{daemon_name}/env/APP_ROOT" > /dev/null]
  queue! %[echo "#{fluent_bin}" | sudo tee "/service/#{daemon_name}/env/BIN" > /dev/null]
end

def worker_remove(hostport)
  worker_init_variables(hostport)
  worker_clean_daemontools

  queue! %[num=$(ls -d /service/fluentd_* 2> /dev/null | wc -l)]
  # remove rpm
  queue! %[[ $num -eq 0 ] && sudo yum -y remove td-agent]
  queue! %[[ $num -eq 0 ] && sudo rm -f /etc/yum.repos.d/fluent-agent-lite-haikanko.repo]
  queue! %[[ $num -eq 0 ] && sudo rm -f /etc/yum.repos.d/td.repo]
  # remove fluentd plugins
  queue! %[[ $num -eq 0 ] && sudo rm -rf #{fluentd_to}]

  run!
  History.worker_removed!(hostport) unless simulate_mode?
end

def worker_clean_daemontools
  remove_daemontools(daemon_name)
  queue! %[sudo rm -rf #{daemontools_to}]
end

def worker_restart(hostport)
  worker_init_variables(hostport)
  restart_daemontools(daemon_name)
end

def worker_start(hostport)
  worker_init_variables(hostport)
  start_daemontools(daemon_name)
end

def worker_stop(hostport)
  worker_init_variables(hostport)
  stop_daemontools(daemon_name)
end

def worker_status
  worker_init_variables(hostport)
  status_daemontools(daemon_name)
  queue! %[ps auxwww | grep bin/fluentd]
end

