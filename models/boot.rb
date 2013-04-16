# encoding: utf-8
require_relative '../boot'

Bootloader.load_mongoid
require_relative 'resource'
require_relative 'group_resource'
require_relative 'feature'
Bootloader.load_dir('models')
Mongoid.logger = nil # turn off mongoid logger
