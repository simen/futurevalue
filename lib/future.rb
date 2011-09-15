module Future
  class Value
    class ValueNeverArrived < Exception
    end

    def initialize(&block)
      @thread = Thread.new(&block)
    end

    def value
      @thread.value
    end

    def done?
      !@thread.alive?
    end

    def error?
      @thread.status == nil
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
      if @thread.alive?
        "#<#{self.class.name} value=[[pending]]>"
      else
        begin
          "#<#{self.class.name} value=#{self.value.inspect}>"
        rescue
          "#<#{self.class.name} value=[[failed]]>"
        end
      end
    end
  end
end