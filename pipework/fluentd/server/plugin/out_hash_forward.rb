class Fluent::HashForwardOutput < Fluent::Output
  Fluent::Plugin.register_output('hash_forward', self)

  config_param :remove_prefix, :string, :default => nil
  config_param :add_prefix, :string, :default => nil

  def configure(conf)
    super

    if @remove_prefix
      @removed_prefix_string = @remove_prefix + '.'
      @removed_length = @removed_prefix_string.length
    end
    if @add_prefix
      @added_prefix_string = @add_prefix + '.'
    end

    @servers = []
    @forward_elements = []
    conf.elements.each {|element|
      if element.name == "server"
        element["weight"] = 100
        @servers.push(element)
      else
        @forward_elements.push(element)
      end
    }
    conf.elements.clear

    @forward_conf = {}
    conf.each {|k, v|
      if !self.class.config_params.keys.index(k.to_sym) and k != "type"
        @forward_conf[k] = v
        conf.delete(k)
      end
    }

    @forward = @servers.map {|server|
      elements = @forward_elements + [server]
      plant(@forward_conf, elements)
    }

    self
  end

  def shutdown
    super
    @forward.each do |output|
      output.shutdown
    end
  end

  def spec(conf, elements)
    Fluent::Config::Element.new('instance', '', conf, elements)
  end

  def plant(conf, elements)
    output = nil
    server = elements.last["host"]+":"+elements.last["port"]
    begin
      output = Fluent::Plugin.new_output('forward')
      output.configure(spec(conf, elements))
      output.start
      $log.info "out_hash_forward plants new output: for server '#{server}'"
    rescue Fluent::ConfigError => e
      $log.error "failed to configure sub output: #{e.message}"
      $log.error e.backtrace.join("\n")
      $log.error "Cannot output messages with server '#{server}'"
      output = nil
    rescue StandardError => e
      $log.error "failed to configure/start sub output: #{e.message}"
      $log.error e.backtrace.join("\n")
      $log.error "Cannot output messages with server '#{server}'"
      output = nil
    end
    output
  end

  def emit(tag, es, chain)
    if @remove_prefix and
        ( (tag.start_with?(@removed_prefix_string) and tag.length > @removed_length) or tag == @remove_prefix)
      tag = tag[@removed_length..-1]
    end 
    if @add_prefix
      tag = if tag.length > 0
              @added_prefix_string + tag
            else
              @add_prefix
            end
    end

    index = server_index(tag)
    output = @forward[index]
    if output
      output.emit(tag, es, chain)
    else
      chain.next
    end
  end

  def server_index(tag)
    require 'murmurhash3'
    MurmurHash3::V32.str_hash(tag) % @servers.size
  end
end
