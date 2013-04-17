# encoding: utf-8

require File.expand_path('boot', File.dirname(__FILE__))

run Rack::URLMap.new(::Web::ROUTES)
