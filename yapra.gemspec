# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "yapra/version"

Gem::Specification.new do |s|
  s.name        = "yapra"
  s.version     = Yapra::VERSION::STRING
  s.authors     = ["yuanying"]
  s.email       = ["yuanying at fraction dot jp"]
  s.homepage    = "http://yapra.rubyforge.org"
  s.summary     = %q{Yet another pragger implementation.}
  s.description = %q{Yet another pragger implementation.}

  s.rubyforge_project = "yapra"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib", "lib-plugins"]

  # specify any dependencies here; for example:
  s.add_development_dependency "rspec"
  s.add_runtime_dependency "mechanize"
end
