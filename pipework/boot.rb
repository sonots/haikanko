# encoding: utf-8
require_relative '../boot'
Bundler.require(:default, :pipework)
require 'mina'
require 'mina/bundler'
require 'mina/rails'
require 'mina/git'
require 'mina/rbenv'

Bootloader.load_dir('pipework')
Bootloader.load_dir('pipework/lib')
Bootloader.load_dir('pipework/mina')

set :user, ENV['USER'] if ENV['USER']
set :ssh_options, "-T" # fluent-agent-lite did not start with ssh -t. why? something is happening to disown, maybe

Dir.glob("#{mina_dir}/*.rb").each do |filename|
  namespace File.basename(filename, ".rb") do
    load filename
  end
end
