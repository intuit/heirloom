# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "heirloom/version"

Gem::Specification.new do |s|
  s.name        = "heirloom"
  s.version     = Heirloom::VERSION
  s.authors     = ["Brett Weaver"]
  s.email       = ["brett@weav.net"]
  s.homepage    = ""
  s.summary     = %q{I help with artifacts}
  s.description = %q{I help build and manage artifacts}

  s.rubyforge_project = "heirloom"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  # specify any dependencies here; for example:
  s.add_development_dependency "rspec"

  s.add_runtime_dependency 'fog'
  s.add_runtime_dependency 'grit'
  s.add_runtime_dependency 'logger'
  s.add_runtime_dependency 'minitar'
  s.add_runtime_dependency 'trollop'
end
