require 'thread'

module Future
  class Threadpool
    def initialize(count)
      @queue = Queue.new
      @workers = []
      self.workers = count
    end

    def workers
      @workers.size
    end

    def workers=(value)
    	raise ArgumentError, "Worker count must be >= 0" if value < 0
    	if value > workers
    		(value-workers).times { @workers << new_worker }
    	else
    		(workers-value).times { @queue << proc { @workers.delete(Thread.current); Thread.current.exit } }
    	end
    end

    def << (job)
      @queue << job
    end

    private

    def new_worker
      Thread.new do
        loop do 
          begin
            @queue.pop.call 
          rescue Exception => e
            puts e
            puts e.backtrace
          end
        end
      end
    end
  end
end