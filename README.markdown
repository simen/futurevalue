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
    c = Future::Value.new { sleep(1); "future!" }
    # the moment the content of the values is needed, the main tread blocks until data is ready
    "#{a} #{b} #{c}"
      => Hello from the future
    # total time taken: 3 seconds as opposed to 6 with the traditional way

Future::Threadpool
==================

Future::Value use a nice and simple threadpool to process the values. By default a pool with seven workers is launched when you request your first Future::Value. If you need to adjust the number of workers you'll do this:

    Future::Value.pool.workers = 12

Remember that if you use Future::Value with ActiveRecord you should visit your database.yml-file and make sure your database connection pool match the number of workers you employ.

If you need to wait for all jobs to finish and shut down the worker threads you do this:

    Future::Value.pool.close

The Future::Threadpool is a useful little class in itself and can be put to good use for purposes besides computing future values. Here's how you use it:

    # Creates a pool with 12 active workers
    pool = Future::Threadpool.new(12)

    # Resizes the pool by killing or adding worker threads
    pool.workers = 6

    # Adds a job to the pool
    pool << proc do
      # Work you'd like to have done in parallel
      # Probably involving IO seeing as ruby doesn't really utilize more than one 
      # cpu core anyway.
    end

    # Waits for all pending jobs to finish then proceeds to kill the workers one by one
    pool.close

A word of warning: Future::Threadpool will never be garbage collected if you let it out of your scope without closing it first, because the sleeping workers will keep a reference to it:

    # How to leak memory and threads:
    pool = Future::Threadpool.new(12)
    pool = nil
    # Congrats: you have just leaked an instance of Future::Threadpool + 12 sleeping threads 

So kids, remember this: Close your pools if you plan to lose track of them.
    