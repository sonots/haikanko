# encoding: utf-8

module Web
  class FrontController < ResourceController
    set :views, File.join(File.dirname(__FILE__), '..', 'views', 'front')
    set :layout, '../layouts/plain'

    get '/' do
      herb :frontpage
    end

    # from search form
    get '/feature' do
      redirect '/' unless label = params['label']
      redirect '/' unless feature = Feature.find_by(label: label)
      redirect feature.notifier? ? "/web/notifier/#{feature.id}" :
        (feature.visualizer? ? "/web/visualizer/#{feature.id}" : '/')
    end
  end
end
