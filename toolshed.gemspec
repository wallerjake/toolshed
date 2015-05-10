# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'toolshed/version'

Gem::Specification.new do |spec|
  spec.name          = "toolshed"
  spec.version       = Toolshed::VERSION
  spec.authors       = ["Jake Waller"]
  spec.email         = ["wallerjake@gmail.com"]
  spec.description   = %q{Utility that will automate simple daily tasks developers perform like creating a Github pull request}
  spec.summary       = %q{Create a Github pull request with minimal work. Will automatically read ticket information from pivotal tracker if you use that.}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  #spec.executables   = ["toolshed"]
  spec.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test)/})
  spec.require_paths = ["lib"]

  spec.add_dependency "httparty"
  spec.add_dependency "json"
  spec.add_dependency "pivotal-tracker"
  spec.add_dependency 'harvested', '3.1.1'
  spec.add_dependency "veto"
  spec.add_dependency "launchy"
  spec.add_dependency "clipboard"
  spec.add_dependency "jira-ruby"
  spec.add_dependency "net-ssh"

  spec.add_development_dependency "bundler"
  spec.add_development_dependency "rake"
  spec.add_development_dependency 'mocha'
  spec.add_development_dependency 'faker'
  spec.add_development_dependency 'test-unit'
  spec.add_development_dependency 'pry-byebug'
  spec.add_development_dependency 'ci_reporter'
  spec.add_development_dependency 'simplecov'
  spec.add_development_dependency 'codeclimate-test-reporter'
end
