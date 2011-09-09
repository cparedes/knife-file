$:.unshift(File.dirname(__FILE__) + '/lib')
require 'knife-file/version'

Gem::Specification.new do |s|
  s.name = 'knife-file'
  s.version = KnifeFile::VERSION
  s.platform = Gem::Platform::RUBY
  s.has_rdoc = true
  s.extra_rdoc_files = ["README.rdoc", "LICENSE" ]
  s.summary = "Utilities for manipulating files with knife"
  s.description = s.summary
  s.author = "Christian Paredes"
  s.email = "cp@redbluemagenta.com"
  s.homepage = "http://redbluemagenta.com"

  s.add_dependency "chef", ">= 0.9.14"
  s.require_path = 'lib'
  s.files = %w(LICENSE README.rdoc) + Dir.glob("lib/**/*")
end
