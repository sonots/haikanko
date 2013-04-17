# encoding: utf-8

module SinatraHelper

  def self.included(controller)
    controller.helpers do

      def h(text)
        Rack::Utils.escape_html(text)
      end

      def checked_if(boolean)
        attr_if(:checked, boolean)
      end

      def selected_if(boolean)
        attr_if(:selected, boolean)
      end

      def hidden_if(boolean)
        attr_if(:hidden, boolean)
      end

      def disabled_if(boolean)
        attr_if(:disabled, boolean)
      end

      def autofocused_if(boolean)
        attr_if(:autofocus, boolean)
      end

      def id_for(expr)
        attr_for(:id, expr)
      end

      def class_for(expr)
        attr_for(:class, expr)
      end

      def value_for(expr)
        attr_for(:value, expr)
      end

      def name_for(expr)
        attr_for(:name, expr)
      end

      def href_for(expr, opts={})
        if opts.fetch(:relative, true)
          attr_for(:href, "/web#{expr}")
        else
          attr_for(:href, expr)
        end
      end

      # @param attr [Symbol]
      # @param expr [String]
      # @return [String]
      def attr_if(attr, boolean)
        attr.to_s if boolean
      end

      # @param attr [Symbol]
      # @param expr [String]
      # @return [String]
      def attr_for(attr, expr)
        %[#{attr}="#{expr}"]
      end

    end
  end
end
