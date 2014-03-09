#!/usr/bin/env ruby
require 'fileutils'
require 'optparse'
require 'yaml'
require 'xo/args'

module Xo
	module Apps
		class BackupSites
			def initialize
        parse_options
				@config = get_config
				@args[:backup_dir] = File.expand_path(@config['backup_directory'])
			end

			def run
				@config['sites'].each do |site, site_entry|
					now = Time.new
					site_dir = "#{@args[:backup_dir]}/#{site}"
					FileUtils.mkpath(site_dir)

					if site_entry['directories']
						site_entry['directories'].each do |directory, directory_entry|
							site_files = "#{site_dir}/#{directory}"
							file = "#{site_dir}/#{site}-#{now.strftime('%Y%m%d')}.tar.gz"
							File.delete(file) if File.exist?(file)

							verbose_flag = @args[:verbose] ? 'v' : ''
							execute("rsync -a#{verbose_flag} --delete #{site_entry['ssh']}:#{directory} #{site_dir}/")
							FileUtils.cd(site_dir)
							execute("tar cz#{verbose_flag}f #{file} #{directory}")
						end
					end

					if site_entry['databases']
						site_entry['databases'].each do |database, database_entry|
							file = "#{site_dir}/#{site}-#{database}-#{now.strftime('%Y%m%d')}.sql"
							File.delete(file) if File.exist?(file)
							File.delete("#{file}.gz") if File.exist?("#{file}.gz")

							execute("mysqldump -h #{site_entry['host']} -u #{database_entry['user']} --password='#{database_entry['password']}' #{database} --set-gtid-purged=OFF --disable-keys --add-drop-table >#{file} 2>/dev/null")
							execute("gzip #{file}")
						end
					end
				end
			end

			private

      def parse_options
        @args = Xo::Args.instance.set :config_file => '~/.backup_sites.yml'
        OptionParser.new do |opts|
          opts.banner = "Usage: backup_sites [options]"
          opts.on("-v", "--[no-]verbose", "Run verbosely") do |v|
            @args[:verbose] = v
          end
        end.parse!
      end

      def get_config
        config_file = File.expand_path @args[:config_file]
        raise "No config file #{config_file}" unless File.exists? config_file
        config = YAML.load_file(config_file)
      end
      
			def execute(command)
				puts command if @args[:verbose]
				ok = system(command)
				raise "[#{command}] returned [#{$?}]" unless ok
			end
		end
	end
end
