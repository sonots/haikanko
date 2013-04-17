#!/usr/bin/env ruby
# -*- encoding: utf-8 -*-
require_relative '../boot'
require 'growthforecast-client'
require 'optparse'

$uri = FluentdConfig.growthforecast.uri
# parse options
OptionParser.new do |opt|
  Version = "1.0.0"
  opt.on('-u URI','--uri URI','URI of growthforecast such as http://localhost:5125') { |uri| $uri = uri }
  opt.on('-h','--help','show this message') { puts opt; exit }
  begin
    opt.parse!
  rescue
    puts "Invalid option. \nsee #{opt}"
    exit
  end 
end
URI.parse($uri).tap {|uri| $uri = "#{uri.scheme}://#{uri.host}:#{uri.port}" }

def cumulative_count
  client = GrowthForecast::Client.new($uri)

  list_graph = client.list_graph
  all_counts = {}
  list_graph.each do |graph|
    service_name, section_name, graph_name = graph['service_name'], graph['section_name'], graph['graph_name']
    next unless graph_name =~ /count/
    next if section_name == 'all'
    all_counts[service_name] ||= {}
    all_counts[service_name][graph_name] ||= 0
    number = client.get_graph(service_name, section_name, graph_name)['number']
    all_counts[service_name][graph_name] += number
    print '.'
  end
  puts

  all_counts.each do |service_name, counts|
    counts.each do |graph_name, number|
      puts "/#{service_name}/all/#{graph_name}"
      client.post_graph(service_name, "all", graph_name, { 'number' => number, 'mode' => 'gauge' })
    end
  end
end

def avg_avg
  client = GrowthForecast::Client.new($uri)

  list_graph = client.list_graph
  all_counts = {}
  list_graph.each do |graph|
    service_name, section_name, graph_name = graph['service_name'], graph['section_name'], graph['graph_name']
    next unless graph_name =~ /avg/
    next if section_name == 'all'
    all_counts[service_name] ||= {}
    all_counts[service_name][graph_name] ||= 0
    number = client.get_graph(service_name, section_name, graph_name)['number']
    all_counts[service_name][graph_name] = [all_counts[service_name][graph_name], number].max # max of avg just for now
    print '.'
  end
  puts

  all_counts.each do |service_name, counts|
    counts.each do |graph_name, number|
      puts "/#{service_name}/all/#{graph_name}"
      client.post_graph(service_name, "all", graph_name, { 'number' => number, 'mode' => 'gauge' })
    end
  end
end

def min_min
  client = GrowthForecast::Client.new($uri)

  list_graph = client.list_graph
  all_counts = {}
  list_graph.each do |graph|
    service_name, section_name, graph_name = graph['service_name'], graph['section_name'], graph['graph_name']
    next unless graph_name =~ /min/
    next if section_name == 'all'
    all_counts[service_name] ||= {}
    all_counts[service_name][graph_name] ||= 0
    number = client.get_graph(service_name, section_name, graph_name)['number']
    all_counts[service_name][graph_name] = [all_counts[service_name][graph_name], number].min
    print '.'
  end
  puts

  all_counts.each do |service_name, counts|
    counts.each do |graph_name, number|
      puts "/#{service_name}/all/#{graph_name}"
      client.post_graph(service_name, "all", graph_name, { 'number' => number, 'mode' => 'gauge' })
    end
  end
end

def max_max
  client = GrowthForecast::Client.new($uri)

  list_graph = client.list_graph
  all_counts = {}
  list_graph.each do |graph|
    service_name, section_name, graph_name = graph['service_name'], graph['section_name'], graph['graph_name']
    next unless graph_name =~ /max/
    next if section_name == 'all'
    all_counts[service_name] ||= {}
    all_counts[service_name][graph_name] ||= 0
    number = client.get_graph(service_name, section_name, graph_name)['number']
    all_counts[service_name][graph_name] = [all_counts[service_name][graph_name], number].max
    print '.'
  end
  puts

  all_counts.each do |service_name, counts|
    counts.each do |graph_name, number|
      puts "/#{service_name}/all/#{graph_name}"
      client.post_graph(service_name, "all", graph_name, { 'number' => number, 'mode' => 'gauge' })
    end
  end
end

max_max
min_min
avg_avg
cumulative_count

