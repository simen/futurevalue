require 'rubygems'
require 'rake'
require 'rake/rdoctask'

begin
  require 'jeweler'
  Jeweler::Tasks.new do |gem|
    gem.name = 'future'
    gem.summary = gem.description = %Q{A promise of a value to be calculated in the future}
    gem.email = "simen@bengler.no"
    gem.homepage = "http://github.com/simen/future"
    gem.authors = ["Simen Svale Skogsrud"]
    gem.has_rdoc = true
    gem.require_paths = ["lib"]
    gem.files = FileList[%W(
      README.markdown
      VERSION
      LICENSE*
      lib/**/*
    )]
  end
  Jeweler::GemcutterTasks.new
rescue LoadError
  $stderr << "Warning: Gem-building tasks are not included as Jeweler (or a dependency) not available. Install it with: `gem install jeweler`.\n"
end

Rake::RDocTask.new do |rdoc|
  version = File.exist?('VERSION') ? File.read('VERSION') : ""

  rdoc.rdoc_dir = 'rdoc'
  rdoc.title = "ruby-hdfs #{version}"
  rdoc.rdoc_files.include('README*')
  rdoc.rdoc_files.include('lib/**/*.rb')
end
