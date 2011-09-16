Future
======

A little class to represent a promise of a value that will be provided at a later time. Useful to perform asynchronous operations without fouling the code up with event oriented cruft. A Future::Value can generally be used in place of the future value it represents.

Without Future:

    # Get a number of feed items and concatenate them without Future::Value
    Benchmark.measure do
      ['chewy', 'han solo', 'r2d2', 'yoda', 'c3po', 'at-at'].map do |name|
        JSON.parse(Net::HTTP.get(URI.parse("http://api.twitter.com/search.json?q=rubygems")))['results']
      end.flatten
    end.real
      => 4.5 # seconds
    

The same code with the requests and processing wrapped in a Future::Value

    # Get a number of feed items and concatenate them *with* Future::Value
    Benchmark.measure do
      ['chewy', 'han solo', 'r2d2', 'yoda', 'c3po', 'at-at'].map do |name|
        Future::Value.new { JSON.parse(Net::HTTP.get(URI.parse("http://api.twitter.com/search.json?q=rubygems")))['results'] }
      end.flatten
    end.real
      => 0.8 # seconds

Installation
============

Not yet published as a gem, so you'll have to

    git clone git@github.com:simen/future.git
    cd future
    rake install

Or if you use the awesomeness that is bundler, you stick this in your Gemfile:

    gem "future", :git => git@github.com:simen/future.git

Usage
=====

Basically a Future::Value wraps a thread in such a way that it looks like you get the result of a time consuming operation directly. Not until you try to access the result will the thread actually block. In this way you may write asynchronous code that looks like traditional straight down ruby. Especially useful for performing a number of http-requests and let them run in parallel while you perform other tasks.

    # a, b and c are all "calculated" in parallel.
    a = Future::Value.new { sleep(2); "Hello" }
    b = Future::Value.new { sleep(3); "from the"}
    c = Future::VAlue.new { sleep(1); "future!" }
    # the moment the content of the values is needed, the main tread blocks until data is ready
    "#{a} #{b} #{c}"
      => Hello from the future
    # total time taken: 3 seconds as opposed to 6 with the traditional way
