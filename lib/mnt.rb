require 'fileutils'
require 'optparse'
require 'yaml'

module Xo
  class Mnt
    def initialize
      @options = {
        :verbose => true,
        :unmount => false,
        :config_file => '~/.mnt.conf',
      }

      parse_options
      @config = get_config

    end

    def run
      ARGV.each do |tag|
        unless @config['filesystems'].has_key?(tag)
          warn "#{tag} is not a valid tag"
          next
        end
        create_mountpoint(tag)
        command = build_command(tag)
        puts command if @options[:verbose]
        result = `#{command}`
        puts result if @options[:verbose]
        puts "Unable to mount #{tag}" unless $?.success?
      end
    end

    private

    def parse_options
      OptionParser.new do |opts|
        opts.banner = "Usage: mnt [options]"
        opts.on("-u", "--unmount", "Unmount instead of mount") do |u|
          @options[:unmount] = u
        end
        opts.on("-v", "--[no-]verbose", "Run verbosely") do |v|
          @options[:verbose] = v
        end
      end.parse!
    end

    def get_config
      config_file = File.expand_path @options[:config_file]
      raise "No config file #{config_file}" unless File.exists? config_file

      config = YAML.load_file(config_file)
      config['filesystems'] ||= {}
      config['filesystems'].each_key do |tag|
        this = config['filesystems'][tag]
        this ||= {}
        this['ssh'] ||= tag
        this['remote_directory'] ||= "/home/#{tag}"
        this['local_directory'] ||= "#{config['mountpoint']}/#{tag}"
      end

      config
    end

    def create_mountpoint(tag)
      FileUtils.makedirs(@config['filesystems'][tag]['local_directory'])
    end

    def build_command(tag)
      if @options[:unmount]
        command = String.new(@config['unmountcommand'])
      else
        command = String.new(@config['mountcommand'])
        command.gsub!('{remote_directory}', @config['filesystems'][tag]['remote_directory'])
        command.gsub!('{ssh}', @config['filesystems'][tag]['ssh'])
        command.gsub!('{tag}', tag)
      end
      command.gsub!('{local_directory}', @config['filesystems'][tag]['local_directory'])
    end

  end

end
