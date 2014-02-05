require "bundler/gem_tasks"
require 'rake/testtask'

require File.expand_path(File.dirname(__FILE__)) + "/test/config"

Rake::TestTask.new do |t|
  t.libs << 'test'
  t.test_files = FileList['test/**/*.rb']
end

desc "Run tests"
task default: :test
