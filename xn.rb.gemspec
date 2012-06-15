# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "xn/version"

Gem::Specification.new do |s|
  s.name        = "xn.rb"
  s.version     = Xn::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["David Colebatch", "Darrick Wiebe", "Scott Hyndman"]
  s.email       = ["dc@xnlogic", "dw@xnlogic", "sh@lightmesh.com"]
  s.homepage    = "http://www.xnlogic.com/"
  s.summary     = %q{XN Logic API client - first used by LightMesh utilities}
  s.description = %q{Aims to provide a semantic wrapper for the XN Logic graph-db application framework's REST API.}
  
  s.add_dependency 'highline'
  s.add_development_dependency 'rspec'
  s.add_development_dependency 'simplecov'
  s.add_development_dependency 'autotest'
  s.add_development_dependency 'autotest-growl'
  s.add_development_dependency 'awesome_print', '0.4.0'

  s.rubyforge_project = "xn.rb"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
end

