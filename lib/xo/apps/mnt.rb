require 'fileutils'
require 'optparse'
require 'yaml'
require 'xo/args'

module Xo
  module Apps
    
    class Mnt
      def initialize
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
          puts command if @args[:verbose]
          result = `#{command}`
          puts result if @args[:verbose]
          puts "Unable to mount #{tag}" unless $?.success?
        end
      end

      private

      def parse_options
        @args = Xo::Args.instance.set :verbose => true, :unmount => false, :config_file => '~/.mnt.conf'
        OptionParser.new do |opts|
          opts.banner = "Usage: mnt [options]"
          @args.add_arg_verbose(opts)
          opts.on("-u", "--unmount", "Unmount instead of mount") do |v|
            @args[:unmount] = v
          end
        end.parse!
      end

      def get_config
        config_file = File.expand_path @args[:config_file]
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
        if @args[:unmount]
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
end
