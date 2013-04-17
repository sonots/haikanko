# encoding: utf-8

module Sinatra
  module Rendering

    module Helpers

      def herb(template, options={})
        erb(template, options.merge(:layout => :"#{settings.layout}"))
      end

    end

    def self.registered(app)
      app.helpers Rendering::Helpers
      app.set :layout, 'default'
    end

  end

  register Rendering
end
