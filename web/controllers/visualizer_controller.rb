# encoding: utf-8

module Web
  class VisualizerController < ResourceController
    set :views, File.join(File.dirname(__FILE__), '..', 'views', 'visualizer')
    set :layout, './layout'
    include ::Web::DeployHelper

    before do
      set_visualizers
      set_role_autocomplete
      set_irc_autocomplete
      set_email_autocomplete
      set_tab :visualizer
    end

    # I was ever a REST votary, but ...
    get '/' do
      herb :index
    end

    get '/new' do
      @visualizer = Visualizer.new
      herb :edit
    end

    post '/new' do
      data = preprocess_form_data(params['visualizer'])
      @visualizer = Visualizer.create(data)

      if @visualizer.error?
        @errors = @visualizer.errors
        herb :edit
      else
        redirect "/web/visualizer/#{@visualizer.id}?s=1"
      end
    end

    get '/:visualizer_id' do |visualizer_id|
      redirect '/' unless @visualizer = Visualizer.find(visualizer_id)
      herb :edit
    end

    post '/:visualizer_id' do |visualizer_id|
      redirect '/' unless @visualizer = Visualizer.find(visualizer_id)
      data = preprocess_form_data(params['visualizer'])
      @visualizer.update_attributes(data)

      if @visualizer.error?
        @errors = @visualizer.errors
        herb :edit
      else
        redirect "/web/visualizer/#{@visualizer.id}?s=2"
      end
    end

    post '/:visualizer_id/disable' do |visualizer_id|
      redirect '/' unless @visualizer = Visualizer.find(visualizer_id)
      @visualizer.disable!

      if @visualizer.error?
        @errors = @visualizer.errors
        herb :edit
      else
        redirect "/web/visualizer/#{@visualizer.id}?s=5"
      end
    end

    post '/:visualizer_id/enable' do |visualizer_id|
      redirect '/' unless @visualizer = Visualizer.find(visualizer_id)
      @visualizer.enable!

      if @visualizer.error?
        @errors = @visualizer.errors
        herb :edit
      else
        redirect "/web/visualizer/#{@visualizer.id}?s=6"
      end
    end

    post '/:visualizer_id/delete' do |visualizer_id|
      @visualizer = Visualizer.find(visualizer_id)
      if @visualizer.destroy
        redirect "/web/visualizer?s=3"
      else
        @errors = @visualizer.errors
        herb :edit
      end
    end

    post '/:visualizer_id/duplicate' do |visualizer_id|
      redirect '/' unless visualizer = Visualizer.find(visualizer_id)
      data = preprocess_form_data(params['visualizer'])
      @visualizer = visualizer.duplicate(data)

      if @visualizer.error?
        @visualizer.on_errors(visualizer_id)
        @errors = @visualizer.errors
        herb :edit
      else
        redirect "/web/visualizer/#{@visualizer.id}?s=4"
      end
    end

    def preprocess_form_data(params)
      return {} unless params.present?
      data = params.dup

      data['roles'] = Role.finds(params['roles'].values)
      data['hosts'] = Host.makes(params['hosts'].values)
      data['ircs'] = Irc.finds(params['ircs'].values)
      data['emails'] = Email.finds(params['emails'].values)

      data
    end

    def set_visualizers
      @visualizers = Visualizer.all.sort do |a, b|
        a.label.downcase <=> b.label.downcase
      end
    end
  end
end
