module Future
  class Value
    @@pool = nil

    DEFAULT_WORKER_COUNT = 7

    def self.workers=(value)      
      raise ArgumentError, "Worker count cannot be changed. Set worker count before computing your first Future::Value" if @@pool
      @@pool = Future::Threadpool.new(value)
      ObjectSpace.define_finalizer(self, proc { @@pool.each(&:kill) })
    end

    def self.workers
      return nil unless @@pool
      @@pool.count
    end

    def initialize(&block)
      Future::Value.workers ||= DEFAULT_WORKER_COUNT
      @result = Queue.new
      @done = false
      @exception = nil
      @@pool << lambda do
        begin
          @result << block.call 
        rescue Exception => e
          @exception = e
          @done = true
        end
      end
    end

    def value      
      unless @done
        @value = @result.pop
        @done = true
      end
      raise @exception if @exception        
      @value
    end

    def done?
      @done || @result.length > 0
    end

    def error?
      !@exception.nil?
    end

    def method_missing(method, *args, &block)      
      self.value.send(method, *args, &block) 
    end

    def to_s
      self.value.to_s
    end
    
    def to_str
      self.value.to_str
    end

    def inspect 
      if !done?
        "#<#{self.class.name} value=[[pending]]>"
      else
        unless error?
          "#<#{self.class.name} value=#{self.value.inspect}>"
        else
          "#<#{self.class.name} value=#{@exception.inspect}>"
        end
      end
    end
  end
end