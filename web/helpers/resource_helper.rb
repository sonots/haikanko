# encoding: utf-8

module Web
  module ResourceHelper
    def success_message(value=params['s'])
      case value
      when '1'
        'Created.'
      when '2'
        'Updated.'
      when '3'
        'Deleted.'
      when '4'
        'Duplicated.'
      when '5'
        'Disabled.'
      when '6'
        'Enabled.'
      end
    end

    def action_href(resource, action)
      return "/web/#{resource.class.to_s.underscore}/new" if action == :create
      return "/web/#{resource.class.to_s.underscore}/#{resource.id}" if action == :update
      "/web/#{resource.class.to_s.underscore}/#{resource.id}/#{action}"
    end

    def create_button(resource)
      return unless resource.new?
      return <<-HTML
        <button type="submit" class="btn btn-primary" onclick="form.action='#{h(action_href(resource, :create))}'">
          Create
        </button>
      HTML
    end

    def update_button(resource)
      return if resource.new?
      return <<-HTML
        <button type="submit" class="btn btn-primary" onclick="form.action='#{h(action_href(resource, :update))}'">
          Update
        </button>
      HTML
    end

    def disable_button(resource)
      return if resource.disabled?
      return if resource.new?
      return <<-HTML
        <a href="#{h(action_href(resource, :disable))}" class="btn" role="button" data-method="post">
          <i class="icon-off"></i>Disable
        </a>
      HTML
    end

    def enable_button(resource)
      return if resource.enabled?
      return if resource.new?
      return <<-HTML
        <a href="#{h(action_href(resource, :enable))}" class="btn" role="button" data-method="post">
          <i class="icon-ok"></i>Enable
        </a>
      HTML
    end

    def duplicate_button(resource)
      return if resource.new?
      return <<-HTML
        <button type="submit" class="btn" onclick="form.action='#{h(action_href(resource, :duplicate))}'">
          <i class="icon-plus-sign"></i>Duplicate
        </button>
      HTML
    end

    def delete_button(resource)
      return if resource.new?
      return <<-HTML
        <a href="#{h(action_href(resource, :delete))}" class="btn btn-danger" role="button" data-method="post" data-confirm="true">
          Delete
        </a>
      HTML
    end
  end
end
