# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require 'knife-file/version'

Gem::Specification.new do |s|
  s.name = 'knife-file'
  s.version = Knife::File::VERSION
  s.platform = Gem::Platform::RUBY
  s.has_rdoc = true
  s.extra_rdoc_files = ["README.rdoc", "LICENSE" ]
  s.summary = "Utilities for manipulating files with knife"
  s.description = s.summary
  s.author = "Christian Paredes"
  s.email = "cp@redbluemagenta.com"
  s.homepage = "http://redbluemagenta.com"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.add_dependency "chef", ">= 0.9.14"
  s.require_paths = ['lib']
end
