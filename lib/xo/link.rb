require 'optparse'
require 'xo/directory/link'

module Xo
  class Link
    def initialize
      @options = {
        :package_dir => "/opt/xecko",
        :verbose => true,
      }

      parse_options
    end

    def run
      get_packages_to_link.each do |package|
        Xo::Directory::Link.new("#{@options[:package_dir]}/#{package}", "#{@options[:package_dir]}").process
      end
    end

    private

    def parse_options
      OptionParser.new do |opts|
        opts.banner = "Usage: xolink [options]"
        opts.on("-v", "--[no-]verbose", "Run verbosely") do |v|
          @options[:verbose] = v
        end
        opts.on("-p", "--package-dir DIR", "Specify package directory") do |dir|
          @options[:package_dir] = dir
        end
      end.parse!
    end

    def get_packages_to_link
      packages_to_link = []
      Dir.new(@options[:package_dir]).each do |entry|
        next if entry =~ /^\./
        next unless entry =~ /-/
        next unless File.directory?("#{@options[:package_dir]}/#{entry}")
        packages_to_link.push(entry)
      end
      packages_to_link
    end

  end

end
