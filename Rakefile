require 'rspec/core/rake_task'
require 'yard'

task :default => [:test, :yard]

task :test => :spec

RSpec::Core::RakeTask.new(:spec)

YARD::Rake::YardocTask.new do |t|
end