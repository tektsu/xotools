require 'singleton'

module Xo
  class Args
    include Singleton
    
    # Xo::Args is a singleton class for sharing command line arguments
    # with throughout a program.
    #
    # It provides a base of flag values which are always present. These
    # values may be used by other Xo::* classes. These values interact,
    # and setting one may affect others. For example, :verbose and :quiet
    # cannot both be set.
    #
    # Additional key/value pairs may be added.
    #
    # @author Steve Baker
    
    def initialize
      @args = {
        :debug => false,
        :verbose => false,
        :quiet => false,
        :force => false,
        :noaction => false,
      }
    end
    
    def set(args)
      args.each {|key, value| @args[key] = value}
      self
    end
    
    def []=(key, value)
      @args[key] = value;
      if @args[key]
        if key == :debug
          @args[:verbose] = true
          @args[:quiet] = false
        elsif key == :verbose
          @args[:debug] = false
          @args[:quiet] = false
        elsif key == :quiet
          @args[:debug] = false
          @args[:verbose] = false
        elsif key == :force
          @args[:noaction] = false
        elsif key == :noaction
          @args[:force] = false
        end
      end
    end
    
    def [](key)
      @args[key]
    end
   
    def add_arg_debug(opts)
      opts.on("-d", "--[no]-debug", "Print extra debugging information") do |v|
        self[:debug] = v
      end
    end
   
    def add_arg_verbose(opts)
      opts.on("-v", "--[no-]verbose", "Run verbosely") do |v|
        self[:verbose] = v
      end
    end
   
    def add_arg_quiet(opts)
      opts.on("-q", "--quiet", "Print no output") do |v|
        self[:quiet] = v
      end
    end
   
    def add_arg_noaction(opts)
      opts.on("-n", "--noaction", "Take no action") do |v|
        self[:noaction] = v
      end
    end
   
    def add_arg_force(opts)
      opts.on("-f", "--force", "Force action") do |v|
        self[:force] = v
      end
    end
  end
end
