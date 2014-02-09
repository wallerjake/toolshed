require 'config'
require 'test/unit'
require 'mocha/test_unit'
require 'faker'
require 'veto'

require 'toolshed'

Test::Unit.at_start do
  Toolshed::Client.use_git_submodules = false

  if (Dir.exists? (File.join(TEST_ROOT, "tmp")))
    Dir.rmdir(File.join(TEST_ROOT, "tmp"))
  end

  Dir.mkdir(File.join(TEST_ROOT, "tmp"), 0777)
  Dir.chdir(File.join(TEST_ROOT, "tmp"))

  # setup the new repository with an empty set this is configured in the config.rb file
  system("git init")
  system("git remote add origin git@github.com:#{GITHUB_USERNAME}/#{GITHUB_SAMPLE_REPO}.git")
  system("git fetch")
  system("git checkout -t origin/master")
end

Test::Unit.at_exit do
  FileUtils.rm_rf(File.join(TEST_ROOT, "tmp"))
end
