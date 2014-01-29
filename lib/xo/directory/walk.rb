module Xo
  module Directory
    
    class Walk
      
      # @return [String]
      attr_reader :directory

      # @param directory [String] the directory to examine
      def initialize(directory, ignore_hidden: false, dir_cb: nil, file_cb: nil, dfs: false)
        @top = directory
        @ignore_hidden = ignore_hidden
        @dir_cb = dir_cb
        @file_cb = file_cb
        @dfs = dfs
      end
      
      # Process the directories recursively. Normally called initially with no parameter.
      #
      # @param path [String] the relative path to process
      # @return [void]
      def process(path='')
        full_path = "#{@top}/#{path}"

        directories = []
        files = []
        Dir.new(full_path).each do |entry|
          next if entry == '.' || entry == '..'
          next if entry =~ /^\./ && @ignore_hidden
          full_entry = "#{full_path}/#{entry}"
          if File.directory?(full_entry)
            directories.push(entry)
          else
            files.push(entry)
          end
        end
        
        if @dfs
          process_directories(path, directories)
          process_files(path, files)
        else
          process_files(path, files)
          process_directories(path, directories)
        end
      end
      
      private
      
      def process_directories(path, directories)
        directories.each do |directory|
          if @dir_cb
            result = @dir_cb.call(@top, path, directory)
            next if result == :prune
          end
          next_path = (path != '' ? "#{path}/" : '') << directory
          process(next_path)
        end
      end

      def process_files(path, files)
        files.each do |file|
          p @top, path, file
          @file_cb.call(@top, path, file) if @file_cb
        end
      end
      
    end
  end
end

file_code = lambda {|top, path, file| puts "File: #{top}/#{path}/#{file}"}
dir_code = lambda {|top, path, dir| puts "Dir:  #{top}/#{path}/#{dir}" ; return :prune if dir == '.git'}
Xo::Directory::Walk.new("/Users/steve/Development/xotools", dir_cb: dir_code, file_cb: file_code).process