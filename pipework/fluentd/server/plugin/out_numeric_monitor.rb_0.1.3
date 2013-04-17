class Fluent::NumericMonitorOutput < Fluent::Output
  Fluent::Plugin.register_output('numeric_monitor', self)

  EMIT_STREAM_RECORDS = 100

  config_param :count_interval, :time, :default => 60
  config_param :unit, :string, :default => nil
  config_param :tag, :string, :default => 'monitor'

  config_param :aggregate, :default => 'tag' do |val|
    case val
    when 'tag' then :tag
    when 'all' then :all
    else
      raise Fluent::ConfigError, "aggregate MUST be one of 'tag' or 'all'"
    end
  end
  config_param :input_tag_remove_prefix, :string, :default => nil
  config_param :monitor_key, :string
  config_param :percentiles, :default => nil do |val|
    values = val.split(",").map(&:to_i)
    if values.select{|i| i < 1 or i > 99 }.size > 0
      raise Fluent::ConfigError, "percentiles MUST be specified between 1 and 99 by integer"
    end
    values
  end

  config_param :samples_limit, :integer, :default => 1000000

  attr_accessor :count, :last_checked

  def configure(conf)
    super

    if @unit
      @count_interval = case @unit
                        when 'minute' then 60
                        when 'hour' then 3600
                        when 'day' then 86400
                        else
                          raise Fluent::ConfigError, "unit must be one of minute/hour/day"
                        end
    end

    if @input_tag_remove_prefix
      @removed_prefix_string = @input_tag_remove_prefix + '.'
      @removed_length = @removed_prefix_string.length
    end
    
    @count = count_initialized
    @mutex = Mutex.new
  end

  def start
    super
    start_watch
  end

  def shutdown
    super
    @watcher.terminate
    @watcher.join
  end

  def start_watch
    # for internal, or tests
    @watcher = Thread.new(&method(:watch))
  end

  def watch
    @last_checked = Fluent::Engine.now
    while true
      sleep 0.5
      if Fluent::Engine.now - @last_checked > @count_interval
        now = Fluent::Engine.now
        flush_emit
        @last_checked = now
      end
    end
  end

  def count_initialized(keys=nil)
    # counts['tag'] = {:min => num, :max => num, :sum => num, :num => num [, :sample => [....]]}
    if @aggregate == :all
      if @percentiles
        {'all' => {:min => nil, :max => nil, :sum => nil, :num => 0, :sample => []}}
      else
        {'all' => {:min => nil, :max => nil, :sum => nil, :num => 0}}
      end
    elsif keys
      values = if @percentiles
                 Array.new(keys.length) {|i| {:min => nil, :max => nil, :sum => nil, :num => 0, :sample => []}}
               else
                 Array.new(keys.length) {|i| {:min => nil, :max => nil, :sum => nil, :num => 0}}
               end
      Hash[[keys, values].transpose]
    else
      {}
    end
  end

  def stripped_tag(tag)
    return tag unless @input_tag_remove_prefix
    return tag[@removed_length..-1] if tag.start_with?(@removed_prefix_string) and tag.length > @removed_length
    return tag[@removed_length..-1] if tag == @input_tag_remove_prefix
    tag
  end

  def generate_output(count)
    output = {}
    if @aggregate == :all
      c = count['all']
      if c[:num] then output['num'] = c[:num] end
      if c[:min] then output['min'] = c[:min] end
      if c[:max] then output['max'] = c[:max] end
      if c[:num] > 0 then output['avg'] = (c[:sum] * 100.0 / (c[:num] * 1.0)).round / 100.0 end
      if @percentiles
        sorted = c[:sample].sort
        @percentiles.each do |p|
          i = (c[:num] * p / 100).floor
          if i > 0
            i -= 1
          end
          output["percentile_#{p}"] = sorted[i]
        end
      end
      return output
    end

    count.keys.each do |tag|
      t = stripped_tag(tag)
      c = count[tag]
      if c[:num] then output[t + '_num'] = c[:num] end
      if c[:min] then output[t + '_min'] = c[:min] end
      if c[:max] then output[t + '_max'] = c[:max] end
      if c[:num] > 0 then output[t + '_avg'] = (c[:sum] * 100.0 / (c[:num] * 1.0)).round / 100.0 end
      if @percentiles
        sorted = c[:sample].sort
        @percentiles.each do |p|
          i = (c[:num] * p / 100).floor
          if i > 0
            i -= 1
          end
          output[t + "_percentile_#{p}"] = sorted[i]
        end
      end
    end
    output
  end

  def flush
    flushed,@count = @count,count_initialized(@count.keys.dup)
    generate_output(flushed)
  end

  def flush_emit
    Fluent::Engine.emit(@tag, Fluent::Engine.now, flush)
  end

  def countups(tag, min, max, sum, num, sample)
    if @aggregate == :all
      tag = 'all'
    end

    @mutex.synchronize do
      c = (@count[tag] ||= {:min => nil, :max => nil, :sum => nil, :num => 0})
      
      if c[:min].nil? or c[:min] > min
        c[:min] = min
      end
      if c[:max].nil? or c[:max] < max
        c[:max] = max
      end
      c[:sum] = (c[:sum] || 0) + sum
      c[:num] += num

      if @percentiles
        c[:sample] ||= []
        if c[:sample].size + sample.size > @samples_limit
          (c[:sample].size + sample.size - @samples_limit).times do
            c[:sample].delete_at(rand(c[:sample].size)) 
          end
        end
        c[:sample] += sample
      end
    end
  end

  def emit(tag, es, chain)
    min = nil
    max = nil
    sum = 0
    num = 0
    sample = if @percentiles then [] else nil end

    es.each do |time,record|
      value = record[@monitor_key]
      next if value.nil?

      value = value.to_f
      if min.nil? or min > value
        min = value
      end
      if max.nil? or max < value
        max = value
      end
      sum += value
      num += 1

      if @percentiles
        sample.push(value)
      end
    end
    if @percentiles && sample.size > @samples_limit
      (sample.size - @samples_limit / 2).to_i.times do
        sample.delete_at(rand(sample.size))
      end
    end
    countups(tag, min, max, sum, num, sample)

    chain.next
  end
end
