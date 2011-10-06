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
      if value > workers
        (value-workers).times { @workers << new_worker }
      else
        (workers-value).times { @queue << proc { @workers.delete(Thread.current); Thread.current.exit } }
      end
    end

    def << (job)
      @queue << job
    end

    def close
      self.workers = 0
      @workers.each(&:join)
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