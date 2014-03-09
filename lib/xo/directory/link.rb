require 'xo/directory/walk'
require 'xo/args'

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
      # @param raise_on_error [Boolean] throw an exception on an error, true or false
      def initialize(source, target, raise_on_error: false)
        @args = Xo::Args.instance
        @source = source
        @target = target
        @raise = raise_on_error
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

      # Perform the linking from source to target
      #
      # @return [void]
      def link
        Dir.mkdir @target unless Dir.exists? @target
        
        # When we find a directory, create it in the target area
        create_directory = lambda do |path|
          directory = "#{@target}/#{path}"
          Dir.mkdir directory unless Dir.exists? directory
        end
        
        # When we find a file, symlink it in the target area
        create_symlink = lambda do |path|
          source = "#{@source}/#{path}"
          target = "#{@target}/#{path}"
          if File.exists?(target)
            if File.symlink?(target)
              if File.readlink(target) == source
                return
              end
            else
              message = "#{target} exists and is not a symlink"
              puts message if @args[:verbose]
              raise message if @raise
              return
            end
          end
          puts "Creating #{target} -> #{source}" if @args[:verbose]
          File.unlink(target) if File.exists?(target)
          File.symlink(source, target)
        end
        
        Xo::Directory::Walk.new(@source, dir_cb: create_directory, file_cb: create_symlink).process
      end

    end
  end
end