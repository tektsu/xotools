require 'optparse'
require 'xo/directory/dvds'

module Xo
  module Apps
    
    class Dvds
      def initialize
        parse_options
      end
  
      def run
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
      
    end
  end
end