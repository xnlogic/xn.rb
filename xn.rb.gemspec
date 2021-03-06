# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "xn/version"

Gem::Specification.new do |s|
  s.name        = "xn.rb"
  s.version     = Xn::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["David Colebatch", "Darrick Wiebe"]
  s.email       = ["dc@xnlogic", "dw@xnlogic"]
  s.homepage    = "http://www.xnlogic.com/"
  s.summary     = %q{XN Logic API client - first used by LightMesh utilities}
  s.description = %q{Aims to provide a semantic wrapper for the XN Logic graph-db application framework's REST API.}
  s.required_rubygems_version = '>= 2.2.0'
  s.metadata['allowed_push_host'] = 'https://push.not.allowed'

  s.add_dependency 'highline'
  s.add_development_dependency 'xn_gem_release_tasks', '>= 0.1.19'

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.require_paths = ["lib"]
end

