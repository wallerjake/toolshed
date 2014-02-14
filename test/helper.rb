require 'config'
require 'test/unit'
require 'mocha/test_unit'
require 'faker'
require 'veto'
require 'fileutils'
require 'json'

require 'toolshed'

Test::Unit.at_start do
  Toolshed::Client.use_git_submodules = false
  Toolshed::Client.git_quiet = '&> /dev/null'

  I18n.config.enforce_available_locales = true

  # setup a fake remote directory so we can reference everything locally
  system("rm -r -f #{File.join(TEST_ROOT, "remote")}")
  if (Dir.exists? (File.join(TEST_ROOT, "remote")))
    Dir.rmdir(File.join(TEST_ROOT, "remote"))
  end

  Dir.mkdir(File.join(TEST_ROOT, "remote"), 0777)
  Dir.chdir(File.join(TEST_ROOT, "remote"))

  # setup a couple of branches acting as the remote repository
  system('git init &> /dev/null')
  FileUtils.touch('file.txt')
  system('git add * &> /dev/null')
  system('git commit -m"Add empty file as commit" &> /dev/null')
  system('git checkout -b development master &> /dev/null')

  system("rm -r -f #{File.join(TEST_ROOT, "tmp")}")
  if (Dir.exists? (File.join(TEST_ROOT, "tmp")))
    Dir.rmdir(File.join(TEST_ROOT, "tmp"))
  end

  Dir.mkdir(File.join(TEST_ROOT, "tmp"), 0777)
  Dir.chdir(File.join(TEST_ROOT, "tmp"))


  # setup the new repository with an empty set this is configured in the config.rb file
  system("git init &> /dev/null")
  system("git remote add origin #{File.join(TEST_ROOT, "remote")} &> /dev/null")
  system('git fetch &> /dev/null')
  system('git checkout -t origin/master &> /dev/null')
end

Test::Unit.at_exit do
  FileUtils.rm_rf(File.join(TEST_ROOT, "remote"))
  FileUtils.rm_rf(File.join(TEST_ROOT, "tmp"))
end
