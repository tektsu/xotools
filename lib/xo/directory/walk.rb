module Xo
  module Directory
    
    class Walk
      
      # @return [String]
      attr_reader :directory

      # @param directory [String] the directory to examine
      def initialize(directory, ignore_hidden: false, dir_cb: nil, file_cb: nil)
        @directory = directory
        @ignore_hidden = ignore_hidden
        @dir_cb = dir_cb
        @file_cb = file_cb
      end
      
      # Process the directories recursively. Normally called initially with no parameter
      # to start processing at the directory passed to the constructor.
      #
      # @param path [String] the relative path to process
      # @return [void]
      def process(path=nil)
        directories = []
        files = []
        full_path = @directory + (path ? "/#{path}" : '')
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
        
        process_files(path, files)
        process_directories(path, directories)
      end
      
      private
      
      def normalize_path(path)
        path ? "#{path}/": ''
      end
      
      def process_directories(path, directories)
        normalized_path = normalize_path(path)
        directories.each do |directory|
          full_path = "#{normalized_path}#{directory}"
          if @dir_cb
            result = @dir_cb.call(full_path)
            next if result == :prune
          end
          process(full_path)
        end
      end

      def process_files(path, files)
        normalized_path = normalize_path(path)
        files.each do |file|
          @file_cb.call("#{normalized_path}#{file}") if @file_cb
        end
      end
      
    end
  end
end
