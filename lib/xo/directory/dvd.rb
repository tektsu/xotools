require 'fileutils'
require 'find'

module Xo
  module Directory
    
    class Dvd
      
      attr_reader :path, :max_size, :current_size
      
      def initialize(path, size=(4.2 * 1024 * 1024 * 1024))
        @path = File.expand_path(path)
        raise "Directory path #{@path} already exists" if File.exists?(@path)
        FileUtils.mkpath(@path)
        @max_size = size
        @current_size = 0
      end
      
      def remaining_space
        @max_size - @current_size
      end
      
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
