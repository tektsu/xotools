module Xo
  module Directory
    
    class Walk
      
      # @return [String]
      attr_reader :directory

      # @param directory [String] the directory to examine
      def initialize(directory, verbose: false)
        @directory = directory
        @verbose = verbose
      end
      
      # Set or clear the verbose flag
      #
      # @param state [Boolean] the new state, true or false
      # @return [void]
      def verbose(state=true)
        @verbose = state ? true : false
      end
      
      # Get the value of the verbose flag
      #
      # @return [Boolean]
      def verbose?
        @verbose
      end
    end
  end
end