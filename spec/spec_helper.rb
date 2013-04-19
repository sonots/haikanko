# encoding: utf-8

ENV['RACK_ENV'] = 'test'
require 'bundler/setup'
Bundler.require(:default, :test)
require_relative '../web/boot'
require 'capybara/rspec'
require 'coveralls'
Coveralls.wear!

Dir["#{Bootloader.root_path}/spec/*/spec_helper.rb"].each { |f| require f }
Dir["#{Bootloader.root_path}/spec/support/**/*.rb"].each { |f| require f }
Dir["#{Bootloader.root_path}/spec/**/support/**/*.rb"].each { |f| require f }

RSpec.configure do |config|
  # config.mock_with :mocha
  config.include Delorean

  # Capybara
  # Capybara.javascript_driver = :webkit
  Capybara.app = Rack::URLMap.new(::Web::ROUTES)
  config.include Capybara::DSL, :example_group => { :file_path => %r"spec/controllers" }

  # Clean up all collections before each spec runs
  config.before do
    Mongoid.purge!
    Irc.fabricate!
    Email.fabricate!
  end

  # Clean up all collections before all spec runs
  config.before(:all) do
    Mongoid.purge!
    Irc.fabricate!
    Email.fabricate!
  end
end
