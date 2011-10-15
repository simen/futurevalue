require 'spec_helper'

describe Future::Threadpool do
  it "executes the jobs" do
    p = Future::Threadpool.new(10)
    sentinel = nil
    p << -> { sentinel = "hello" }
    sleep 0.1
    sentinel.should eq "hello"
    p.close
  end

  it "resizes gracefully" do
    initial_threadcount = Thread.list.size
    p = Future::Threadpool.new(10)
    p.workers = 5
    sleep 0.1
    p.workers.should eq 5
    Thread.list.size.should eq initial_threadcount+5
    p.workers = 10
    sleep 0.1
    p.workers.should eq 10
    Thread.list.size.should eq initial_threadcount+10
    p.workers = 0
    sleep 0.1
    p.workers.should eq 0
    Thread.list.size.should eq initial_threadcount
    p.workers = -1
    sleep 0.1
    p.workers.should eq 0
    Thread.list.size.should eq initial_threadcount
    p.close
  end

  it "closes gracefully" do
    former_threadcount = Thread.list.size
    p = Future::Threadpool.new(10)
    20.times { p << -> { 100.times { 1+1 } } }
    p.close
    Thread.list.size.should eq former_threadcount
  end

  it "runs a number of threads" do
    p = Future::Threadpool.new(10)
    p.workers.should eq 10
    p.close
  end

  it "puts jobs on the queue" do
    p = Future::Threadpool.new(0)
    sentinel = nil
    p << -> { sentinel = "hello" }
    job = p.instance_variable_get('@queue').pop
    job.call
    sentinel.should eq "hello"
    p.close
  end

  it "works a lot" do
    p = Future::Threadpool.new(10)
    sentinel = []
    100.times{ p << -> { sentinel << "hepp" } }
    sleep 0.5
    sentinel.size.should == 100
    p.close
  end



end