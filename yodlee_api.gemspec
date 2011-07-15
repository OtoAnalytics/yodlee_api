# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "yodlee_api/version"

Gem::Specification.new do |s|
  s.name        = "yodlee_api"
  s.version     = YodleeApi::VERSION
  s.authors     = ["David Kariuki"]
  s.email       = ["TODO: Write your email address"]
  s.homepage    = ""
  s.summary     = %q{TODO: Write a gem summary}
  s.description = %q{TODO: Write a gem description}

  s.rubyforge_project = "yodlee_api"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
end
