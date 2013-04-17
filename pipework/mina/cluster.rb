# encoding: utf-8

task :restart do
  agent_hosts = Feature.all_hostnames
  worker_hostports = FluentdConfig.workers

  agent_hosts.each do |domain|
    invoke_block(domain) { agent_stop }
  end
  worker_hostports.each do |hostport|
    domain = hostport.split(":")[0]
    invoke_block(domain) { worker_restart(hostport) }
  end
  sleep 1
  agent_hosts.each do |domain|
    invoke_block(domain) { agent_start }
  end
end
