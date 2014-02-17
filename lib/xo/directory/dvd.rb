require 'fileutils'
require 'find'

module Xo
  module Directory
    
    class Dvd
      
      # @param path [String] the directory to create for this dvd (must not exist)
      # @param size [Integer] the maximum number of bytes allowed in the directory
      def initialize(path, size=(4.2 * 1024 * 1024 * 1024))
        @path = File.expand_path(path)
        raise "Directory path #{@path} already exists" if File.exists?(@path)
        FileUtils.mkpath(@path)
        @max_size = size
        @current_size = 0
      end
      
      # Get the path to the dvd directory
      #
      # @return [String]
      attr_reader :path

      # Get the maximum number of bytes allowed in this directory
      #
      # @return [Integer]
      attr_reader :max_size

      # Get the current number of bytes in this directory
      #
      # @return [Integer]
      attr_reader :current_size
      
      # Get the number of free bytes remaining in the directory
      #
      # @return [Integer]
      def remaining_space
        @max_size - @current_size
      end

      # Add a file or directory to the dvd directory
      #
      # @param path [String] the location of file or directory to add
      # @param size [Integer] the size of the file or directory if already known      
      def add(path, size=nil)
        raise "Add path #{path} does not exist" unless File.exists?(path)
        if Dir.exists?(path)
          unless size
            size = 0
            Find.find(path) { |f| size += File.stat(f).size }
          end
        else
          unless size
            size = File.stat(path).size
          end
        end
        raise "#{path} is too big to fit in this directory" if size > remaining_space
        FileUtils.cp_r(path, @path)
        @current_size += size
      end
      
    end
  end
end
