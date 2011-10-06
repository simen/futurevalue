require 'thread'

module Future
  class Threadpool
    def initialize(workers)
      @queue = Queue.new
      @workers = (1..workers).map{ new_worker }
    end

    def count
      @workers.size
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