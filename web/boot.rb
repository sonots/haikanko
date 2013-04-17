# encoding: utf-8
require_relative '../boot'
Bundler.require(:default, :web)

I18n.load_path += Dir[File.join(File.dirname(__FILE__), '../config/locales/*.yml').to_s]

Bootloader.load_dir('web/lib')
Bootloader.load_dir('web/helpers')
require_relative 'controllers/resource_controller'
Bootloader.load_dir('web/controllers')
Bootloader.load_dir('web')

