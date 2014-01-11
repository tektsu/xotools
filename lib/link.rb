require 'optparse'

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
        process_package package
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

    def get_directories_in_package(package)
      package_directories = []
      package_path = "#{@options[:package_dir]}/#{package}"
      package_dir = Dir.new(package_path)
      package_dir.each do |entry|
        next if entry =~ /^\./
        next unless File.directory?("#{package_path}/#{entry}")
        package_directories.push(entry)
      end
      package_directories
    end

    def process_package(package)
      get_directories_in_package(package).each do |directory|
        process_directory(package, directory)
      end
    end

    def create_directory_if_needed(directory)
      Dir.mkdir directory unless Dir.exists? directory
    end

    def create_symlink(source, target)
      puts "Creating #{target} -> #{source}" if @options[:verbose]
      File.unlink(target) if File.exists?(target)
      File.symlink(source, target)
    end

    def create_symlink_if_needed(source, target)
      if File.exists?(target)
        if File.symlink?(target)
          if File.readlink(target) == source
            return
          end
        else
          puts "#{target} exists and is not a symlink" if @options[:verbose]
          return
        end
      end
      create_symlink(source, target)
    end

    def process_directory(package, path)
      source_path = "#{@options[:package_dir]}/#{package}/#{path}"
      target_path = "#{@options[:package_dir]}/#{path}"
      create_directory_if_needed(target_path)

      directories = []
      Dir.new(source_path).each do |entry|
        next if entry =~ /^\./
        source_full = "#{source_path}/#{entry}"
        if File.directory?(source_full)
          directories.push(entry)
        else
          create_symlink_if_needed(source_full, "#{target_path}/#{entry}")
        end
      end

      # Process any additional directories
      directories.each do |directory|
        process_directory(package, "#{path}/#{directory}")
      end
    end
  end

end
