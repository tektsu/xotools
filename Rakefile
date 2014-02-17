require 'rspec/core/rake_task'
require 'yard'

task :default => [:test, :yard, :gem]

task :test => :spec

RSpec::Core::RakeTask.new(:spec)

YARD::Rake::YardocTask.new do |t|
end

task :gem do
  `gem build xotools.gemspec`
end

task :clean do
  FileUtils.rm_rf('doc')
  FileUtils.rm_rf('.yardoc')
  FileUtils.rm_rf('_yardoc')
  FileUtils.rm_rf(Dir.glob('*.gem'))
end