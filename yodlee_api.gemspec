# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "yodlee_api/version"

Gem::Specification.new do |s|
  s.name        = "yodlee_api"
  s.version     = YodleeApi::VERSION
  s.authors     = ["David Kariuki"]
  s.email       = ["david@otoanalytics.com"]
  s.homepage    = "https://github.com/OtoAnalytics/yodlee_api"
  s.summary     = %q{Soap client for the Yodlee API}
  s.description = %q{Ruby Soap client for the Yodlee API}

  s.rubyforge_project = "yodlee_api"
  s.add_dependency "savon", '>= 0.9.6'

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
end
