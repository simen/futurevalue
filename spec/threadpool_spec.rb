require 'spec_helper'

describe Future::Threadpool do
  it "runs a number of threads" do
    p = Future::Threadpool.new(10)
    p.count.should eq 10
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
end