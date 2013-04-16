# encoding: utf-8

module Web
  module AutocompleteHelper
    def set_feature_autocomplete
      @features = Feature.all.sort do |a, b|
        a.label.downcase <=> b.label.downcase
      end
      @feature_autocomplete = @features.map do |p|
        {name: p.label, value: p.label }
      end.to_json
    end

    def set_role_autocomplete
      Role.refresh if Role.readonly?
      @roles = Role.all.sort do |a, b|
        a.label.downcase <=> b.label.downcase
      end
      @role_autocomplete = @roles.map do |p|
        {name: p.label, value: p.label }
      end.to_json
    end

    def set_email_autocomplete
      Email.refresh if Email.readonly?
      @emails = Email.all.sort do |a, b|
        a.label.downcase <=> b.label.downcase
      end
      @email_autocomplete = @emails.map do |p|
        {name: p.label, value: p.label }
      end.to_json
    end

    def set_irc_autocomplete
      Irc.refresh if Irc.readonly?
      @ircs = Irc.all.sort do |a, b|
        a.label.downcase <=> b.label.downcase
      end
      @irc_autocomplete = @ircs.map do |p|
        {name: p.label, value: p.label }
      end.to_json
    end
  end
end
