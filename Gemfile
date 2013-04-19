# encoding: utf-8
source 'https://rubygems.org'

gem 'bootloader', git: 'https://github.com/ngmoco/bootloader'
gem 'activesupport'
gem 'mongoid', '~> 3.0'
gem 'rake'

group :web do
  gem 'unicorn'
  gem 'sinatra', require: 'sinatra/base'
  gem 'sinatra-contrib'
  gem 'dropkick'
end

group :pipework, :web do
  gem 'mina', git: 'https://github.com/sonots/mina', branch: 'master'
  gem 'tilt'
  gem 'parallel'
  gem 'growthforecast-client'
end

group :development, :test do
  gem 'fluentd'
  gem 'foreman'
  gem 'fabrication'
  gem 'rspec'
  gem 'mocha', require: ['mocha/api']
  gem 'pry'
  gem 'pry-nav'
  gem 'rb-fsevent'
  gem 'guard'
  gem 'guard-rspec'
  gem 'delorean'
  gem 'capybara'
  gem 'coveralls', require: false
  # gem 'capybara-webkit', git: 'https://github.com/thoughtbot/capybara-webkit', tag: "v0.14.1"
end
