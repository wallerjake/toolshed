# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'toolshed/version'

Gem::Specification.new do |spec|
  spec.name          = 'toolshed'
  spec.version       = Toolshed::VERSION
  spec.authors       = ['Jake Waller']
  spec.email         = ['wallerjake@gmail.com']
  spec.description   = %q{Utility that will automate simple daily tasks developers perform like creating a Github pull request} # rubocop:disable Metrics/LineLength
  spec.summary       = %q{Create a Github pull request with minimal work. Will automatically read ticket information from pivotal tracker if you use that.} # rubocop:disable Metrics/LineLength
  spec.homepage      = ''
  spec.license       = 'MIT'

  spec.files         = `git ls-files`.split($/)
  #spec.executables   = ['toolshed']
  spec.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test)/})
  spec.require_paths = ['lib']

  spec.add_dependency 'httparty', '0.13.5'
  spec.add_dependency 'pivotal-tracker', '0.5.13'
  spec.add_dependency 'harvested', '3.1.1'
  spec.add_dependency 'veto'
  spec.add_dependency 'launchy', '2.4.3'
  spec.add_dependency 'clipboard', '1.0.6'
  spec.add_dependency 'jira-ruby', '0.1.14'
  spec.add_dependency 'net-ssh', '2.9.2'
  spec.add_dependency 'term-ansicolor', '1.3.0'
  spec.add_dependency 'highline', '1.7.2'
  spec.add_dependency 'net-scp', '1.2.1'
  spec.add_dependency 'ruby-progressbar', '1.7.5'

  spec.add_development_dependency 'bundler'
  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'mocha'
  spec.add_development_dependency 'faker'
  spec.add_development_dependency 'test-unit'
  spec.add_development_dependency 'pry-byebug'
  spec.add_development_dependency 'ci_reporter'
  spec.add_development_dependency 'simplecov'
  spec.add_development_dependency 'codeclimate-test-reporter'
  spec.add_development_dependency 'rubocop'
end
