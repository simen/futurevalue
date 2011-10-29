# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "futurevalue/version"

Gem::Specification.new do |s|
  s.name        = "futurevalue"
  s.version     = Future::VERSION
  s.authors     = ["Simen Svale Skogsrud"]
  s.email       = ["simen@bengler.no"]
  s.homepage    = ""
  s.summary     = %q{A promise of a value to be calculated in the future}
  s.description = %q{A promise of a value to be calculated in the future}

  s.rubyforge_project = "futurevalue"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_development_dependency "rspec"
end
