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

  s.rubyforge_project = "xn.rb"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.require_paths = ["lib"]
end

