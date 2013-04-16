# encoding: utf-8

module Web
  class EmailController < ResourceController
    set :views, File.join(File.dirname(__FILE__), '..', 'views', 'email')
    set :layout, './layout'

    before do
      set_emails
      set_tab :email
    end

    # I was ever a REST votary, but ...
    get '/' do
      herb :index
    end

    get '/new' do
      @email = Email.new
      herb :edit
    end

    post '/new' do
      @email = Email.create(params['email'])

      if @email.error?
        @errors = @email.errors
        herb :edit
      else
        redirect "/web/email/#{@email.id}?s=1"
      end
    end

    get '/:email_id' do |email_id|
      redirect '/' unless @email = Email.find(email_id)
      herb :edit
    end

    post '/:email_id' do |email_id|
      redirect '/' unless @email = Email.find(email_id)
      @email.update_attributes(params['email'])

      if @email.error?
        @errors = @email.errors
        herb :edit
      else
        redirect "/web/email/#{@email.id}?s=2"
      end
    end

    post '/:email_id/delete' do |email_id|
      redirect '/' unless @email = Email.find(email_id)
      if @email.destroy
        redirect "/web/email?s=3"
      else
        @errors = @email.errors
        herb :edit
      end
    end

    post '/:email_id/duplicate' do |email_id|
      redirect '/' unless email = Email.find(email_id)
      @email = email.duplicate(params['email'])

      if @email.error?
        @email.on_errors(email_id)
        @errors = @email.errors
        herb :edit
      else
        redirect "/web/email/#{@email.id}?s=4"
      end
    end

    def set_emails
      Email.refresh if Email.readonly?
      @emails = Email.all.sort do |a, b|
        a.label.downcase <=> b.label.downcase
      end
    end
  end
end
