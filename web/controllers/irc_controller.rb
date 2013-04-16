# encoding: utf-8

module Web
  class IrcController < ResourceController
    set :views, File.join(File.dirname(__FILE__), '..', 'views', 'irc')
    set :layout, './layout'

    before do
      set_ircs
      set_tab :irc
    end

    # I was ever a REST votary, but ...
    get '/' do
      herb :index
    end

    get '/new' do
      @irc = Irc.new
      herb :edit
    end

    post '/new' do
      @irc = Irc.create(params['irc'])

      if @irc.error?
        @errors = @irc.errors
        herb :edit
      else
        redirect "/web/irc/#{@irc.id}?s=1"
      end
    end

    get '/:irc_id' do |irc_id|
      @irc = Irc.find(irc_id)
      herb :edit
    end

    post '/:irc_id' do |irc_id|
      redirect '/' unless @irc = Irc.find(irc_id)
      @irc.update_attributes(params['irc'])

      if @irc.error?
        @errors = @irc.errors
        herb :edit
      else
        redirect "/web/irc/#{@irc.id}?s=2"
      end
    end

    post '/:irc_id/delete' do |irc_id|
      @irc = Irc.find(irc_id)
      if @irc.destroy
        redirect "/web/irc?s=3"
      else
        @errors = @irc.errors
        herb :edit
      end
    end

    post '/:irc_id/duplicate' do |irc_id|
      redirect '/' unless irc = Irc.find(irc_id)
      @irc = irc.duplicate(params['irc'])

      if @irc.error?
        @irc.on_errors(irc_id)
        @errors = @irc.errors
        herb :edit
      else
        redirect "/web/irc/#{@irc.id}?s=4"
      end
    end

    def set_ircs
      @ircs = Irc.all.sort do |a, b|
        a.label.downcase <=> b.label.downcase
      end
    end
  end
end
