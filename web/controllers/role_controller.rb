# encoding: utf-8

module Web
  class RoleController < ResourceController
    set :views, File.join(File.dirname(__FILE__), '..', 'views', 'role')
    set :layout, './layout'

    before do
      set_roles
      set_tab :role
    end

    # I was ever a REST votary, but ...
    get '/' do
      herb :index
    end

    get '/new' do
      @role = Role.new
      herb :edit
    end

    post '/new' do
      data = preprocess_form_data(params['role'])
      @role = Role.create(data)

      if @role.error?
        @errors = @role.errors
        herb :edit
      else
        redirect "/web/role/#{@role.id}?s=1"
      end
    end

    get '/:role_id' do |role_id|
      redirect '/' unless @role = Role.find(role_id)
      herb :edit
    end

    post '/:role_id' do |role_id|
      redirect '/' unless @role = Role.find(role_id)
      data = preprocess_form_data(params['role'])
      @role.update_attributes(data)

      if @role.error?
        @errors = @role.errors
        herb :edit
      else
        redirect "/web/role/#{@role.id}?s=2"
      end
    end

    post '/:role_id/delete' do |role_id|
      redirect '/' unless @role = Role.find(role_id)
      if @role.destroy
        redirect "/web/role?s=3"
      else
        @errors = @role.errors
        herb :edit
      end
    end

    post '/:role_id/duplicate' do |role_id|
      redirect '/' unless role = Role.find(role_id)
      data = preprocess_form_data(params['role'])
      @role = role.duplicate(data)

      if @role.error?
        @role.on_errors(role_id)
        @errors = @role.errors
        herb :edit
      else
        redirect "/web/role/#{@role.id}?s=4"
      end
    end

    def preprocess_form_data(params)
      return {} unless params.present?
      data = params.dup

      data['hosts'] = params['hosts'].split(",").map(&:chomp)

      data
    end

    def set_roles
      @roles = Role.all.sort do |a, b|
        a.label.downcase <=> b.label.downcase
      end
    end
  end
end
