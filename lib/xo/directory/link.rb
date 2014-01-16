module Xo
  module Directory
    class Link
      attr_reader :source, :target
      def initialize(source, target)
        @source = source
        @target = target
        @verbose = false
        @raise = false
      end

      def verbose(state=true)
        @verbose = state ? true : false
      end

      def verbose?
        @verbose
      end

      def raise_on_error(state=true)
        @raise = state ? true : false
      end

      def raise_on_error?
        @raise
      end

      def get_full_paths(path)
        source = @source.dup
        target = @target.dup
        if path
          source << "/#{path}"
          target << "/#{path}"
        end
        return [source, target]
      end

      def process(path=nil)
        source_path, target_path = get_full_paths(path)
        create_directory_if_needed(target_path)
        this_level = path ? "#{path}/" : ''

        # Create a symlink for each file and a list of any directories
        directories = []
        Dir.new(source_path).each do |entry|
          next if entry =~ /^\./
          source_full = "#{source_path}/#{entry}"
          if File.directory?(source_full)
            directories.push(entry)
          else
            create_symlink_if_needed("#{this_level}#{entry}")
          end
        end

        # Process any additional directories
        directories.each do |directory|
          process("#{this_level}#{directory}")
        end
      end

      def create_directory_if_needed(directory)
        Dir.mkdir directory unless Dir.exists? directory
      end

      def create_symlink(path)
        source_path, target_path = get_full_paths(path)
        puts "Creating #{target_path} -> #{source_path}" if @verbose
        File.unlink(target_path) if File.exists?(target_path)
        File.symlink(source_path, target_path)
      end

      def create_symlink_if_needed(path)
        source_path, target_path = get_full_paths(path)
        if File.exists?(target_path)
          if File.symlink?(target_path)
            if File.readlink(target_path) == source_path
              return
            end
          else
            message = "#{target_path} exists and is not a symlink"
            puts message if @verbose
            raise message if @raise
            return
          end
        end
        create_symlink(path)
      end

    end
  end
end