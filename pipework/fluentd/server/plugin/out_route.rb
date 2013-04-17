#
# Fluent
#
# Copyright (C) 2011 FURUHASHI Sadayuki
#
#    Licensed under the Apache License, Version 2.0 (the "License");
#    you may not use this file except in compliance with the License.
#    You may obtain a copy of the License at
#
#        http://www.apache.org/licenses/LICENSE-2.0
#
#    Unless required by applicable law or agreed to in writing, software
#    distributed under the License is distributed on an "AS IS" BASIS,
#    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#    See the License for the specific language governing permissions and
#    limitations under the License.
#
module Fluent


class RouteOutput < MultiOutput
  Plugin.register_output('route', self)

  class Route
    include Configurable

    config_param :remove_tag_prefix, :string, :default => nil
    config_param :add_tag_prefix, :string, :default => nil
    # TODO tag_transform regexp
    attr_accessor :copy

    def initialize(pattern)
      super()
      if !pattern || pattern.empty?
        pattern = '**'
      end
      @pattern = MatchPattern.create(pattern)
      @tag_cache = {}
    end

    def match?(tag)
      @pattern.match(tag)
    end

    def configure(conf)
      super
      if conf['copy']
        @copy = true
      end
      if @remove_tag_prefix
        @prefix_match = /^#{Regexp.escape(@remove_tag_prefix)}\.?/
      else
        @prefix_match = //
      end
      if @add_tag_prefix
        @tag_prefix = "#{@add_tag_prefix}."
      else
        @tag_prefix = ""
      end
    end

    def copy?
      @copy
    end

    def emit(tag, es)
      ntag = @tag_cache[tag]
      unless ntag
        ntag = tag.sub(@prefix_match, @tag_prefix)
        if @tag_cache.size < 1024  # TODO size limit
          @tag_cache[tag] = ntag
        end
      end
      Engine.emit_stream(ntag, es)
    end
  end

  def initialize
    super
    @routes = []
    @tag_cache = {}
    @match_cache = {}
  end

  config_param :remove_tag_prefix, :string, :default => nil
  config_param :add_tag_prefix, :string, :default => nil
  # TODO tag_transform regexp

  attr_reader :routes

  def configure(conf)
    super

    if @remove_tag_prefix
      @prefix_match = /^#{Regexp.escape(@remove_tag_prefix)}\.?/
    else
      @prefix_match = //
    end
    if @add_tag_prefix
      @tag_prefix = "#{@add_tag_prefix}."
    else
      @tag_prefix = ""
    end

    conf.elements.select {|e|
      e.name == 'route'
    }.each {|e|
      route = Route.new(e.arg)
      route.configure(e)
      @routes << route
    }
  end

  def emit(tag, es, chain)
    ntag, targets = @match_cache[tag]
    unless targets
      ntag = tag.sub(@prefix_match, @tag_prefix)
      targets = []
      @routes.each {|r|
        if r.match?(ntag)
          targets << r
          break unless r.copy?
        end
      }
      if @match_cache.size < 1024  # TODO size limit
        @match_cache[tag] = [ntag, targets]
      end
    end

    case targets.size
    when 0
      return
    when 1
      targets.first.emit(ntag, es)
      chain.next
    else
      unless es.repeatable?
        m = MultiEventStream.new
        es.each {|time,record|
          m.add(time, record)
        }
        es = m
      end
      targets.each {|t|
        t.emit(ntag, es)
      }
      chain.next
    end
  end
end


end

