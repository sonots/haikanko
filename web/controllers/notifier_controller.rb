# encoding: utf-8

module Web
  class NotifierController < ResourceController
    set :views, File.join(File.dirname(__FILE__), '..', 'views', 'notifier')
    set :layout, './layout'
    include ::Web::DeployHelper

    before do
      set_notifiers
      set_role_autocomplete
      set_irc_autocomplete
      set_email_autocomplete
      set_tab :notifier
    end

    # I was ever a REST votary, but ...
    get '/' do
      herb :index
    end

    get '/new' do
      @notifier = Notifier.new
      herb :edit
    end

    post '/new' do
      data = preprocess_form_data(params['notifier'])
      @notifier = Notifier.create(data)

      if @notifier.error?
        @errors = @notifier.errors
        herb :edit
      else
        redirect "/web/notifier/#{@notifier.id}?s=1"
      end
    end

    get '/:notifier_id' do |notifier_id|
      redirect '/' unless @notifier = Notifier.find(notifier_id)
      herb :edit
    end

    post '/:notifier_id' do |notifier_id|
      redirect '/' unless @notifier = Notifier.find(notifier_id)
      data = preprocess_form_data(params['notifier'])
      @notifier.update_attributes(data)

      if @notifier.error?
        @errors = @notifier.errors
        herb :edit
      else
        redirect "/web/notifier/#{@notifier.id}?s=2"
      end
    end

    post '/:notifier_id/disable' do |notifier_id|
      redirect '/' unless @notifier = Notifier.find(notifier_id)
      @notifier.disable!

      if @notifier.error?
        @errors = @notifier.errors
        herb :edit
      else
        redirect "/web/notifier/#{@notifier.id}?s=5"
      end
    end

    post '/:notifier_id/enable' do |notifier_id|
      redirect '/' unless @notifier = Notifier.find(notifier_id)
      @notifier.enable!

      if @notifier.error?
        @errors = @notifier.errors
        herb :edit
      else
        redirect "/web/notifier/#{@notifier.id}?s=6"
      end
    end

    post '/:notifier_id/delete' do |notifier_id|
      @notifier = Notifier.find(notifier_id)
      if @notifier.destroy
        redirect "/web/notifier?s=3"
      else
        @errors = @notifier.errors
        herb :edit
      end
    end

    post '/:notifier_id/duplicate' do |notifier_id|
      redirect '/' unless notifier = Notifier.find(notifier_id)
      data = preprocess_form_data(params['notifier'])
      @notifier = notifier.duplicate(data)

      if @notifier.error?
        @notifier.on_errors(notifier_id)
        @errors = @notifier.errors
        herb :edit
      else
        redirect "/web/notifier/#{@notifier.id}?s=4"
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

    def set_notifiers
      @notifiers = Notifier.all.sort do |a, b|
        a.label.downcase <=> b.label.downcase
      end
    end
  end
end
