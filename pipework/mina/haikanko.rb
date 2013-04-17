# encoding: utf-8

if current_namespace == :haikanko
  set :user, ENV['USER'] if ENV['USER']
  set :shared_paths, ['log']
  set :deploy_to, HaikankoConfig.deploy_to || '$HOME/haikanko'
  set :haikanko_root, "#{deploy_to}/current"
  set :daemon_name, HaikankoConfig.daemon_name || 'haikanko'
  set :repository, HaikankoConfig.repository
  set :branch, HaikankoConfig.branch
  set :domain, HaikankoConfig.host
end

# This task is the environment that is loaded for most commands, such as
# `mina deploy` or `mina rake`.
desc 'Nobody uses'
task :environment do
  invoke :'rbenv:load'
  # invoke :'rvm:use[ruby-1.9.3-p125@default]'
  queue! %[mkdir -p "#{deploy_to}"]
  queue! %[mkdir -p "#{deploy_to}/releases"]
  queue! %[mkdir -p "#{deploy_to}/shared"]
  queue! %[mkdir -p "#{deploy_to}/shared/log"]
end

desc "Deploy Haikanko."
task :deploy => :environment do
  deploy do
    remove_daemontools(daemon_name)

    # cleanup old releases. the last 5 releases are kept
    # invoke :'deploy:cleanup'
    queue %{
      echo "-----> Cleaning up old releases (keeping #{keep_releases!})"
      #{echo_cmd %{cd "#{deploy_to!}/#{releases_path!}" || exit 15}}
      #{echo_cmd %{count=`ls -1d [0-9]* | sort -rn | wc -l`}}
      #{echo_cmd %{remove=$((count > 5 ? count - #{keep_releases} : 0))}}
      #{echo_cmd %{ls -1d [0-9]* | sort -rn | tail -n $remove | sudo xargs rm -rf {}}}
    }

    # git clone, etc
    invoke :'git:clone'
    invoke :'deploy:link_shared_paths'
    invoke :'bundle:install'

    to :launch do
      # rbenv-vars
      queue! %[echo "RACK_ENV=#{ENV['RACK_ENV']}" | sudo tee -a "#{haikanko_root}/.rbenv-vars" > /dev/null]
      queue! %[echo "USER=$(whoami)" | sudo tee -a "#{haikanko_root}/.rbenv-vars" > /dev/null]

      # setup daemontools
      queue! %[sudo mkdir -p "/service"]
      queue! %[sudo ln -snf "#{deploy_to}/current/daemontools" "/service/#{daemon_name}"]
      queue! %[whoami | sudo tee "/service/#{daemon_name}/env/USER" > /dev/null]
      queue! %[echo "#{deploy_to}/current" | sudo tee "/service/#{daemon_name}/env/APP_ROOT" > /dev/null]
      queue! %[echo "#{ENV['RACK_ENV']}" | sudo tee "/service/#{daemon_name}/env/RACK_ENV" > /dev/null]
      queue! %[echo "#{HaikankoConfig.port}" | sudo tee "/service/#{daemon_name}/env/PORT" > /dev/null]
      queue! %[echo "#{HaikankoConfig.host}" | sudo tee "/service/#{daemon_name}/env/BIND" > /dev/null] if HaikankoConfig.bind
    end
  end
end

desc 'Update Haikanko'
task :update => :install # alias 

desc 'Remove Haikanko'
task :remove => :environment do
  # @todo
end

desc 'Restart Haikanko'
task :restart => :environment do
  restart_daemontools(daemon_name)
end

desc 'Start Haikanko'
task :start => :environment do
  start_daemontools(daemon_name)
end

desc 'Stop Haikanko'
task :stop => :environment do
  stop_daemontools(daemon_name)
end

desc 'Status Haikanko'
task :status => :environment do
  status_daemontools(daemon_name)
end

desc 'See log file of haikanko'
task :log do
  queue! "tail -n 100 -f #{haikanko_root}/log/current"
end
