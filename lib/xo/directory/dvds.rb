module Xo
  module Directory
    
    class Dvds
      
      attr_writer :basename
      
      attr_writer :sequence
      
      attr_writer :sequence_length
      
      # @param path [String] the directory in which to store DVD directories
      # @param size [Integer] the maximum number of bytes allowed in each subdirectory directory
      def initialize(path, size=(4.2 * 1024 * 1024 * 1024))
        @path = File.expand_path(path)
        FileUtils.mkpath(@path) unless File.exists?(@path)
        
        @dvds = []
        @basename = 'dvd'
        @sequence = 1
        @sequence_length = 3
        @max_size = size
      end

      # Add a file or directory to the first DVD in which it fits, or create a new DVD to hold it
      #
      # @param path [String] the location of file or directory to add
      def add(path)
        raise "Add path #{path} does not exist" unless File.exists?(path)
        size = 0
        if Dir.exists?(path)
          Find.find(path) { |f| size += File.stat(f).size }
        else
          size = File.stat(path).size
        end
       
        handled = false 
        @dvds.each do |dvd|
          if dvd.remaining_space >= size
            dvd.add(path, size)
            handled = true
            break
          end
        end
        unless handled
          dvd = Xo::Directory::Dvd.new(sprintf("%s%0#{@sequence_length}d", @basename, @sequence), @max_size)
          dvd.add(path, size)
          @dvds << dvd
        end
      end
      
    end
  end
end