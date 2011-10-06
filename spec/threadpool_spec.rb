require 'spec_helper'

describe Future::Threadpool do
  it "runs a number of threads" do
    p = Future::Threadpool.new(10)
    p.workers.should eq 10
  end

  it "puts jobs on the queue" do
    p = Future::Threadpool.new(0)
    sentinel = nil
    p << -> { sentinel = "hello" }
    job = p.instance_variable_get('@queue').pop
    job.call
    sentinel.should eq "hello"
  end

  it "executes the jobs" do
    p = Future::Threadpool.new(10)
    sentinel = nil
    p << -> { sentinel = "hello" }
    sleep 0.1
    sentinel.should eq "hello"
  end

  it "works a lot" do
    p = Future::Threadpool.new(10)
    sentinel = []
    100.times{ p << -> { sentinel << "hepp" } }
    sleep 0.5
    sentinel.size.should == 100
  end

  it "resizes gracefully" do
  	p = Future::Threadpool.new(10)
  	p.workers = 5
  	sleep 0.1
  	p.workers.should eq 5
  	p.workers = 10
  	sleep 0.1
  	p.workers.should eq 10
  	p.workers = 0
  	sleep 0.1
  	p.workers.should eq 0
  	-> {p.workers = -1}.should raise_exception ArgumentError
  end

end