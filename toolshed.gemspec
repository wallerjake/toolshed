# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'toolshed/version'

Gem::Specification.new do |spec|
  spec.name          = "toolshed"
  spec.version       = Toolshed::VERSION
  spec.authors       = ["test"]
  spec.email         = ["test@gmail.com"]
  spec.description   = %q{This is a utility used to automated small tasks like creating a github pull request.}
  spec.summary       = %q{Ditto}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = ["toolshed"]
  #spec.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "httparty"
end
