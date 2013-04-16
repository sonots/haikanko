# encoding: utf-8

module Web
  class ResourceController < Sinatra::Base
    include SinatraHelper
    register Sinatra::Rendering
    register Sinatra::Reloader if Bootloader.development?
    use Rack::MethodOverride
    use ::Web::RequestLogger, $logger
    set :sessions, true
    set :public_folder, File.dirname(__FILE__) + '/../public'
    set :raise_errors, true
    include ::Web::ResourceHelper
    include ::Web::AutocompleteHelper

    configure do
      # let me allow to put in an iframe
      # http://junkawasaki.me/post/43455024904/http-sinatra-iframe
      set :protection, :except => :frame_options
    end

    before do
      set_feature_autocomplete
    end

    def set_tab(tab)
      @tab = tab
    end

    def t(str)
      I18n.t str
    end

    # @param message [String]
    # @return ActiveModel::Errors
    def create_base_error(message)
      ActiveModel::Errors.new(self).tap{|error| error.add :base => message }
    end

  end
end
