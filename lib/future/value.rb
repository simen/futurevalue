module Future
  class Value
    
    MINIMUM_WORKERS = 7
    @pool = Future::Threadpool.new(0)

    class << self
      attr_reader :pool
    end

    def initialize(&block)
      if self.class.pool.workers < MINIMUM_WORKERS
        self.class.pool.workers = MINIMUM_WORKERS 
      end
      
      @response_queue = Queue.new
      @ready = false
      @exception = nil

      self.class.pool << lambda do
        begin
          @response_queue << block.call
        rescue Exception => e
          @exception = e
        end
        @ready = true
      end
    end

    def value            
      if @response_queue
        @value = @response_queue.pop
        @response_queue = nil
      end

      raise @exception if @exception        

      @value
    end

    def ready?
      @ready
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
      if !ready?
        "#<#{self.class.name} value=[[pending]]>"
      else
        unless @exception
          "#<#{self.class.name} value=#{self.value.inspect}>"
        else
          "#<#{self.class.name} #{@exception.inspect}>"
        end
      end
    end
  end
end