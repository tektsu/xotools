require 'optparse'
require 'xo/directory/link'

module Xo
  module Apps
    
    class Link
      def initialize
        parse_options
      end
  
      def run
        get_packages_to_link.each do |package|
          linker = Xo::Directory::Link.new("#{@args[:package_dir]}/#{package}", "#{@args[:package_dir]}")
          linker.verbose(@args[:verbose])
          linker.link
        end
      end
  
      private
  
      def parse_options
        @args = Xo::Args.instance.set :package_dir => "/opt/xecko"
        OptionParser.new do |opts|
          opts.banner = "Usage: xolink [options]"
          opts.on("-p", "--package-dir DIR", "Specify package directory") do |dir|
            @args[:package_dir] = dir
          end
        end.parse!
      end
  
      def get_packages_to_link
        packages_to_link = []
        Dir.new(@args[:package_dir]).each do |entry|
          next if entry =~ /^\./
          next unless entry =~ /-/
          next unless File.directory?("#{@args[:package_dir]}/#{entry}")
          packages_to_link.push(entry)
        end
        packages_to_link
      end
  
    end
  end
end
