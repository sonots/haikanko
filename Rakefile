# encoding: utf-8

desc "Open the console"
task :console do
  require_relative 'boot'
  require 'irb'
  # require 'irb/completion'
  ARGV.clear
  IRB.start
end
task :c => :console

