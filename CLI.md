# Haikanko CLI Manual

## Haikano

If you want to daemonize Haikanko, use [daemontools](http://cr.yp.to/daemontools.html) and `haikanko:deploy` command.

Install daemontools to the host you are deploying Haikanko to

    # yum install daemontools daemontools-toaster
    # echo "SV:12345:respawn:/usr/local/bin/svscanboot" >> /etc/inittab
    # kill -HUP 1

Deployment is done by `mina` command (which is similar with well-known deploy tool `capistrano`) with `haikanko:deploy` sub-command.

    RACK_ENV=staging bundle exec mina haikanko:deploy -S # -S is simulate (dry-run) option
    RACK_ENV=staging bundle exec mina haikanko:deploy -v # -v is verbose option

The `RACK_ENV` variable allows to deploy Haikanko in multi-environment. Add the stage-specific section in `config/haikanko.yml`, `config/fluentd.yml`, and `config/mongoid.yml`.

## Agent

To deploy fluentd agents to application servers, use `agent:deploy`

    RACK_ENV=staging HOST={host1,host2} bundle exec mina agent:deploy -S # -S is simulate (dry-run) option
    RACK_ENV=staging ROLE={role1,role2} bundle exec mina agent:deploy -S # -S is simulate (dry-run) option
    RACK_ENV=staging LABEL={label1,label2} bundle exec mina agent:deploy -S # -S is simulate (dry-run) option

Use HOST to deploy agent(s) to specific hosts. Use ROLE to specify host role groups. 
With LABEL, specify your configured label of Notifier, Visualizer on Haikanko to deploy all agent(s) for the configuration. 

Other `agent` commands are available:

* agent:remove
* agent:update
* agent:start
* agent:status
* agent:stop
* agent:restart
* agent:force_stop

## Worker

Install daemontools to hosts you are deploying fluentd workers to

    # yum install daemontools daemontools-toaster
    # echo "SV:12345:respawn:/usr/local/bin/svscanboot" >> /etc/inittab
    # kill -HUP 1

To deploy fluentd workers, use `worker:deploy`

    RACK_ENV=staging bundle exec mina worker:deploy -S # -S is simulate (dry-run) option
    RACK_ENV=staging HOSTPORT={hostport1,hostport2} bundle exec mina worker:deploy -S # -S is simulate (dry-run) option

Without any options, it deploys fluentd workers to all hosts specified in `config/fluentd.yml`.
With HOSTPORT, you can specify hostnames and ports like HOSTPORT=localhost:22000,localhost:220001

Other `worker` commands are also available:

* worker:remove
* worker:update
* worker:start
* worker:status
* worker:stop
* worker:restart

## Cluster Restart

There is a special command `cluster:restart` to restart entier fluentd clusters.

    RACK_ENV=staging bundle exec mina cluster:restart -S # -S is simulate (dry-run) option

This command stops all agents, restart workers, then start agents. 
