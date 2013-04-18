# Haikanko

Haikanko is a management tool of fluentd cluster

## Why we need Haikanko?

Fluentd achieves a feature by cooperating with lots of fluentd nodes. 
The configuration of each fluentd node must be consistent in terms of both a sender and a receiver. 
However, it is difficult to keep the consistency of this kinds of complicated, entwined cluster architecture by hand. 

Haikanko resolves such issues, and enables to manage a fluentd cluster easily.

## What Haikanko can do?

With Haikanko, you can

- Manage fluend cluster feature configuration on Web UI
- Generate fluend configuration files for each node achieving the specified fluend cluster feature
- Deploy these configuration files by one-click

Currently, Haikanko supports below fluentd cluster features

- Notifier: Watch log files and notifies via IRC or Email if watching keyword is detected
- Visualizer: Visualize metrics obtained from log files

# Dependencies

## Haikanko (Mandatory)

Install belows for Haikanko:

### Ruby

TIPS: I don't really recommend, but you can avoid `error: error setting certificate verify locations:` error of git clone by

    sudo git config --system http.sslverify false

rbenv with ruby-2.0.0-p0 or later and the `bundler` gem installed

    git clone https://github.com/sstephenson/rbenv.git ~/.rbenv
    echo 'export PATH="$HOME/.rbenv/bin:$PATH"' >> ~/.bashrc
    echo 'eval "$(rbenv init -)"' >> ~/.bashrc
    exec $SHELL -l
    mkdir -p ~/.rbenv/plugins
    git clone https://github.com/sstephenson/ruby-build.git ~/.rbenv/plugins/ruby-build
    git clone https://github.com/sstephenson/rbenv-vars.git ~/.rbenv/plugins/rbenv-vars
    rbenv install 2.0.0-p0
    ## Mac OSX
    # brew install openssl
    # brew install readline
    # CC=/usr/bin/gcc-4.2 RUBY_CONFIGURE_OPTS="--with-readline-dir=`brew --prefix readline` --with-openssl-dir=`brew --prefix openssl`" rbenv install 2.0.0-p0
    # chmod 600 /Users/seo.naotoshi/.gem/credentials
    rbenv rehash

### MongoDB

Used as a Haikanko Web Data Store:

i386

    cat << EOT | sudo tee /etc/yum.repos.d/10gen.repo
    [10gen]
    name=10gen Repository
    baseurl=http://downloads-distro.mongodb.org/repo/redhat/os/i686
    gpgcheck=0
    enabled=0
    EOT

x86_64

    cat << EOT | sudo tee /etc/yum.repos.d/10gen.repo
    [10gen]
    name=10gen Repository
    baseurl=http://downloads-distro.mongodb.org/repo/redhat/os/x86_64
    gpgcheck=0
    enabled=0
    EOT

Install and start

    sudo yum install -y --enablerepo=10gen mongo-10gen mongo-10gen-server
    sudo /sbin/chkconfig --add mongod
    sudo /etc/init.d/mongod start

Try

    $ mongo
    mongo> show dbs
    mongo> use [dbname]
    mongo> show collections
    mongo> db.help()
    mongo> db.[collection_name].find()

## Fluentd Worker (Mandatory)

### daemontools

Haikanko is currently taking a fluentd cluster architecture drawn as below:

![fluentd-cluster.png](https://cacoo.com/diagrams/Igc0LFNGavNdG2Ku-CABDD.png?t=1365694058684)

To utilize the CPU resource of worker servers, multiple worker processes should be invoked at a host (typically, the number of processes equals to the number of cores of CPU) with different port numbers. Haikanko uses [daemontools](http://cr.yp.to/daemontools.html) to do it. 

Install daemontools to your fluentd worker hosts

    # yum install daemontools daemontools-toaster
    # echo "SV:12345:respawn:/usr/local/bin/svscanboot" >> /etc/inittab
    # kill -HUP 1

## Fluentd Agent

Requires nothing. Haikanko takes care of them. 

## Visualizer (Optional)

Install belows if you want to use Haikanko's Visualizer feature:

### GrowthForecast

    sudo yum groupinstall "Development Tools"
    sudo yum install pkgconfig glib2-devel gettext libxml2-devel pango-devel cairo-devel

perlbrew + cpanm


    curl -kL http://install.perlbrew.pl | bash
    echo '[[ -s "$HOME/perl5/perlbrew/etc/bashrc" ]] && source "$HOME/perl5/perlbrew/etc/bashrc"' >> .bashrc
    source "$HOME/perl5/perlbrew/etc/bashrc"
    perlbrew install perl-5.16.2
    perlbrew switch perl-5.16.2
    perlbrew install-cpanm

growthforecast

    git clone https://github.com/kazeburo/GrowthForecast.git
    cd GrowthForecast
    cpanm --installdeps .

Run (I use daemontools to daemonize growthforecast actually)

    perl growthforecast.pl --port 5125


## Notifier (Optional)

Install belows if you want to use Haikanko's Notifier feature:

### postfix

Used for sending e-mail. Install if you need a smtp server. 

    sudo yum install postfix
    sudo /etc/init.d/postfix restart

### ircd

IRC server. Install if you need an IRC server. 

    sudo yum --enablerepo=epel install ircd-hybrid
    sudo cp -irp /usr/share/doc/ircd-hybrid-7.2.3/simple.conf /etc/ircd/ircd.conf
    echo "--- /usr/share/doc/ircd-hybrid-7.2.3/simple.conf 2007-02-28 13:17:53.000000000 +0900
    +++ /etc/ircd/ircd.conf 2012-10-09 12:09:41.000000000 +0900
    @@ -12,7 +12,7 @@
      
     serverinfo {
        name = "irc.example.com";
    -   sid = "_CHANGE_ME_";
    +   sid = "1AB";
        description = "Test IRC Server";
        hub = no;
     };" | sudo patch /etc/ircd/ircd.conf
    sudo /etc/init.d/ircd start

### ikachan

Used as an agent for sending message to IRC. 

Install perl

    curl -kL http://install.perlbrew.pl | bash
    echo '[[ -s "$HOME/perl5/perlbrew/etc/bashrc" ]] && source "$HOME/perl5/perlbrew/etc/bashrc"' >> .bashrc
    source "$HOME/perl5/perlbrew/etc/bashrc"
    perlbrew install perl-5.16.0
    perlbrew switch perl-5.16.0
    perlbrew install-cpanm

Install ikachan

    perlbrew switch perl-5.16.0
    cpanm App::Ikachan
    ikachan -S 127.0.0.1 -N ikachan

Try

    curl -F channel=#fluentd-warn http://127.0.0.1:4979/join
    curl -F channel=#fluentd-warn -F message="Hello Haikanko!" http://127.0.0.1:4979/notice

# Development

## Setup

    git clone https://github.com/sonots/haikanko
    cd haikanko
    sudo yum install -y libxslt-devel libxml2-devel
    rbenv local 2.0.0-p0
    rbenv rehash
    gem install bundler
    rbenv rehash
    bundle install
    
## Run the Haikanko

    bundle exec foreman start

You should be able to access Haikanko Web UI via http://your-host:10080. Have a fun with it!

## Run the test suite

    bundle exec rspec

## Configuration

Edit the `config/haikanko.yml`, `config/fluentd.yml`, and `config/mongoid.yml`.

# Deployments and CLI

Haikanko provides a Web UI interfaces, but it does not provide all functions which Haikanko have. See [CLI.md](CLI.md).

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new [Pull Request](../../pull/new/master)

## Copyright

Copyright (c) 2013 Naotoshi SEO. See [LICENSE](LICENSE) for details.
