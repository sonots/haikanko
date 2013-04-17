# A sample Guardfile
# More info at https://github.com/guard/guard#readme

guard 'rspec' do
  notifier(%r{^spec/.+_spec\.rb$})
  notifier('spec/spec_helper.rb')  { "bundle exec spec" }

  notifier(%r{^models/(.+)\.rb$}) { |m| "spec/models/#{m[1]}_spec.rb" }
  notifier(%r{^controllers/(.+)\.rb$}) { |m| "spec/controllers/#{m[1]}_spec.rb" }
end

