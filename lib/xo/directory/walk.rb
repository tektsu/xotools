require 'find'

module Xo
  module Directory
    
    class Walk
      
      # Get the directory this instance will walk
      #
      # @return [String]
      attr_reader :directory

      # @param directory [String] the directory to examine
      def initialize(directory, ignore_hidden: false, dir_cb: nil, file_cb: nil)
        @directory = directory
        @ignore_hidden = ignore_hidden
        @dir_cb = dir_cb
        @file_cb = file_cb
      end
      
      # Process the directories recursively.
      #
      def process
        prefix_length = @directory.length + 1
        Find.find(@directory) do |path|
          rel_path = path[prefix_length..-1]
          next unless rel_path
          Find.prune if File.basename(path)[0] == ?. && @ignore_hidden
          if FileTest.directory?(path)
            if @dir_cb
              result = @dir_cb.call(rel_path)
              Find.prune if result == :prune
            end
          else
            @file_cb.call(rel_path) if @file_cb
          end          
        end
      end

    end
  end
end
