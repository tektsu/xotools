module Xo
  module Directory
    
    # Given a source directory containing files and directories, and a target directory,
    # recreate the directory tree in the target directory, and create symlinks to all
    # files in the source directory.
    #
    # For example, given a source directory that looks like this:
    #
    #  source
    #    file1
    #    dir1
    #      file2
    #      dir2
    #        file3
    #    dir3
    #      file4
    #
    # then the target directory will look like this after the process method is run:
    #
    #  target
    #    file1 -> /source/file1 
    #    dir1
    #      file2 -> /source/dir1/file2
    #      dir2
    #        file3 -> /source/dir1/dir2/file3
    #    dir3
    #      file4 -> /source/dir3/file4
    #
    # Any existing files in source target that do not conflict with those in source
    # are left alone. Conflicting files are considered errors.
    #
    # @author Steve Baker
    class Link
      
      # @return [String]
      attr_reader :source, :target
      
      # @param source [String] the full path to the directory containing files to symlink to
      # @param target [String] the full path to the directory in which to create the symlinks
      def initialize(source, target)
        @source = source
        @target = target
        @verbose = false
        @raise = false
      end

      # Set or clear the verbose flag
      #
      # @param state [Boolean] the new state, true or false
      # @return [void]
      def verbose(state=true)
        @verbose = state ? true : false
      end
      
      # Get the value of the verbose flag
      def verbose?
        @verbose
      end

      # Set or clear the raise_on_error flag. If set, errors will throw an exception, otherwise they are ignored.
      #
      # @param state [Boolean] the new state, true or false
      # @return [void]
      def raise_on_error(state=true)
        @raise = state ? true : false
      end

      # Get the value of the raise_on_error flag
      def raise_on_error?
        @raise
      end

      # Return full source and target paths
      #
      # @param path [String] a relative path
      # @return [Array<String, String>] source and target full paths
      def get_full_paths(path)
        source = @source.dup
        target = @target.dup
        if path
          source << "/#{path}"
          target << "/#{path}"
        end
        return [source, target]
      end

      # Process the directories recursively. Normally called initially with no parameter.
      #
      # @param path [String] the relative path to process
      # @return [void]
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
      
      private

      # Create a directory if it does not already exist
      #
      # @param directory [String] the full path to a directory to create
      def create_directory_if_needed(directory)
        Dir.mkdir directory unless Dir.exists? directory
      end

      # Create a symlink from a path in the target directory to the same path in the source directory
      #
      # @param path [String] a relative path inside the target and source directories
      def create_symlink(path)
        source_path, target_path = get_full_paths(path)
        puts "Creating #{target_path} -> #{source_path}" if @verbose
        File.unlink(target_path) if File.exists?(target_path)
        File.symlink(source_path, target_path)
      end

      # Create a symlink from a path in the target directory to the same path in the source directory
      # if it does not already exist or points to the wrong source file.
      #
      # @param path [String] a relative path inside the target and source directories
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