# encoding: utf-8
require 'bundler/setup'
APP_ROOT = File.expand_path(__dir__)
Bundler.require(:default)
Bundler.require(:development) if Bootloader.development?
$logger = Bootloader.logger($stdout, 'info')
$logger = Bootloader.logger($stdout, 'debug') if Bootloader.development?

Bootloader.load_configs
Bootloader.load_dir('lib')
Bootloader.load_dir('pipework/lib')
require_relative 'models/boot'
