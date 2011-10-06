require 'spec_helper'
require 'benchmark'

Future::Value.workers = 50

describe Future::Value do
  it "forwards missing methods" do
    v = Future::Value.new { [1,2,3] }
    v.value
    v[1].should eq(2)
  end

  it "should be pending until the data arrives" do
    v = Future::Value.new { sleep(1); "hello" }
    v.done?.should eq(false)
    v.value
    v.done?.should eq(true)
    v.value.should eq("hello")
  end

  it "should block until the value is ready upon implicit conversion" do
    v = Future::Value.new { sleep(0.5); "Hello" }
    "#{v} World".should eq("Hello World")
  end

  it "several futures should run together" do
    # Calculating the sum of several futures that each should take one second to appear should take less than three seconds
    Benchmark.measure { (1..50).map { |i| Future::Value.new { sleep(1); i} }.inject(0){ |r, e| r+e } }.real.should be < 3.0
  end

  it "reports errors" do 
    f = Future::Value.new { raise Exception }
    sleep 0.1
    f.error?.should eq(true)
    ->{f.value}.should raise_error(Exception)    
  end

  it "resizes worker amount" do
    Future::Value.workers = 10
    sleep 0.1
    Future::Value.workers.should eq 10
    Future::Value.workers = 1
    sleep 0.1
    Future::Value.workers.should eq 1    
  end

end