module Xo
  module Directory
    class Link
      def initialize(source, target)
        @source = source
        @target = target
      end

      def process(path=nil)
        source_path = @source.dup
        target_path = @target.dup
        if path
          source_path << "/#{path}"
          target_path << "/#{path}"
        end
        create_directory_if_needed(target_path)

        # Create a symlink for each file and a list of any directories
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
        this_level = path ? "#{path}/" : ''
        directories.each do |directory|
          process("#{this_level}#{directory}")
        end
      end

      def create_directory_if_needed(directory)
        Dir.mkdir directory unless Dir.exists? directory
      end

      def create_symlink(source, target)
        puts "Creating #{target} -> #{source}"
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
            puts "#{target} exists and is not a symlink"
            return
          end
        end
        create_symlink(source, target)
      end
      
    end
  end
end