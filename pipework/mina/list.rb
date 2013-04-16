# encoding: utf-8

if current_namespace == :list
  if ENV['ROLE']
    set :roles, ENV['ROLE'].split(",")
  end
end

desc 'Show all lists'
task :all do
  features = roles.present? ? Feature.on_roles(roles) : Feature.all
  puts features.map(&:label).join("\n")
end

desc 'Show all lists of notifiers'
task :notifier do
  features = roles.present? ? Notifier.on_roles(roles) : Notifier.all
  puts features.map(&:label).join("\n")
end

desc 'Show all lists of visualizers'
task :visualizer do
  features = roles.present? ? Visualizer.on_roles(roles) : Visualizer.all
  puts features.map(&:label).join("\n")
end

desc 'Show all roles used'
task :'all:role' do
  features = Feature.all
  puts features.map(&:roles).flatten.uniq.compact.map(&:label).join("\n")
end

desc 'Show all roles used by notifiers'
task :'notifier:role' do
  features = Notifier.all
  puts features.map(&:roles).flatten.uniq.compact.map(&:label).join("\n")
end

desc 'Show all roles used by visualizers'
task :'visualizer:role' do
  features = Visualizer.all
  puts features.map(&:roles).flatten.uniq.compact.map(&:label).join("\n")
end

desc 'Show all hosts used'
task :'all:host' do
  features = Feature.all
  puts features.map(&:hosts).flatten.uniq.compact.map(&:label).join("\n")
end

desc 'Show all hosts used by notifiers'
task :'notifier:host' do
  features = Notifier.all
  puts features.map(&:hosts).flatten.uniq.compact.map(&:label).join("\n")
end

desc 'Show all hosts used by visualizers'
task :'visualizer:host' do
  features = Visualizer.all
  puts features.map(&:hosts).flatten.uniq.compact.map(&:label).join("\n")
end


