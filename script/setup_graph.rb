#!/usr/bin/env ruby
# -*- encoding: utf-8 -*-
require_relative '../boot'
require 'growthforecast-client'
require 'optparse'

def try
  begin
    yield if block_given?
  rescue => e
    $stderr.puts "\tclass:#{e.class}\t#{e.message}"
  end
end

$uri = FluentdConfig.growthforecast.uri
# parse options
OptionParser.new do |opt|
  Version = "1.0.0"
  opt.on('-u URI','--uri URI','URI of growthforecast such as http://localhost:5125') { |uri| $uri = uri }
  opt.on('-s SERVICE_NAME','--service SERVICE_NAME','Service Name of growthforecast') { |service_name| $service_name = service_name }
  opt.on('-h','--help','show this message') { puts opt; exit }
  begin
    opt.parse!
  rescue
    puts "Invalid option. \nsee #{opt}"
    exit
  end 
end
URI.parse($uri).tap {|uri| $uri = "#{uri.scheme}://#{uri.host}:#{uri.port}" }

client = GrowthForecast::Client.new($uri)
list_graph = client.list_graph($service_name)

all_sections = {}
list_graph.each do |graph|
  service_name, section_name, graph_name = graph['service_name'], graph['section_name'], graph['graph_name']
  all_sections[service_name] ||= {}
  all_sections[service_name][section_name] ||= true
end

# configure response_time_max graph
all_sections.each do |service_name, sections|
  sections.each do |section_name, _|
    graph_name = 'response_time_max'
    data = {
      'sort' => 19,
      'adjust' => '/',
      'adjustval' => '1000000',
      'unit' => 'sec',
    }
    puts "Setup /#{service_name}/#{section_name}/#{graph_name}"
    try { client.edit_graph(service_name, section_name, graph_name, data) }

    graph_name = 'response_time_avg'
    data = {
      'sort' => 18,
      'adjust' => '/',
      'adjustval' => '1000000',
      'unit' => 'sec',
    }
    puts "Setup /#{service_name}/#{section_name}/#{graph_name}"
    try { client.edit_graph(service_name, section_name, graph_name, data) }

    graph_name = 'response_time_percentile_99'
    data = {
      'sort' => 17,
      'adjust' => '/',
      'adjustval' => '1000000',
      'unit' => 'sec',
    }
    puts "Setup /#{service_name}/#{section_name}/#{graph_name}"
    try { client.edit_graph(service_name, section_name, graph_name, data) }
  end
end

# configure response time count graphs
colors = {
  '<1sec_count' => '#1111cc',
  '<2sec_count' => '#11cc11',
  '<3sec_count' => '#cc7711',
  '<4sec_count' => '#cccc11',
  '>=4sec_count' => '#cc1111',
}
all_sections.each do |service_name, sections|
  sections.each do |section_name, _|
    # colorize
    %w(<1sec_count <2sec_count <3sec_count <4sec_count >=4sec_count).each do |graph_name|
      data = {
        'color' => colors[graph_name],
        'unit' => 'count',
      }
      puts "Setup /#{service_name}/#{section_name}/#{graph_name}"
      try { client.edit_graph(service_name, section_name, graph_name, data) }
    end

    # complex graph
    from_graphs= colors.map do |graph_name, _|
      {"service_name" => service_name, "section_name" => section_name, "graph_name" => graph_name, "gmode" => "gauge", "stack" => true, "type" => "AREA"}
    end
    to_complex = {
      "service_name" => service_name,
      "section_name" => section_name,
      "graph_name"   => "response_count",
      "sort"         => 10,
    }
    puts "Setup /#{service_name}/#{section_name}/response_count"
    try { client.create_complex(from_graphs, to_complex) }
  end
end

# configure status count graphs
colors = {
  '2xx_count' => '#1111cc',
  '3xx_count' => '#11cc11',
  '400_count' => '#cc7711',
  '4xx_count' => '#cccc11',
  '5xx_count' => '#cc1111',
}
all_sections.each do |service_name, sections|
  sections.each do |section_name, _|
    # colorize
    %w(2xx_count 3xx_count 400_count 4xx_count 5xx_count).each do |graph_name|
      data = {
        'color' => colors[graph_name],
        'unit' => 'count',
      }
      puts "Setup /#{service_name}/#{section_name}/#{graph_name}"
      try { client.edit_graph(service_name, section_name, graph_name, data) }
    end

    # complex graph
    from_graphs= colors.map do |graph_name, _|
      {"service_name" => service_name, "section_name" => section_name, "graph_name" => graph_name, "gmode" => "gauge", "stack" => true, "type" => "AREA"}
    end
    to_complex = {
      'service_name' => service_name,
      'section_name' => section_name,
      'graph_name'   => "status_count",
      'sort'         => 10,
    }
    puts "Setup /#{service_name}/#{section_name}/status_count"
    try { client.create_complex(from_graphs, to_complex) }
  end
end
