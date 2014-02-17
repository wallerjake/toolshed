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
  if (Dir.exists? (File.join(TEST_ROOT, "remote")))
    Dir.rmdir(File.join(TEST_ROOT, "remote"))
  end

  Dir.mkdir(File.join(TEST_ROOT, "remote"), 0777)
  Dir.chdir(File.join(TEST_ROOT, "remote"))

  # setup a couple of branches acting as the remote repository
  until system('git init')
    sleep 1
  end

  FileUtils.touch('file.txt')

  until system('git add file.txt')
    sleep 1
  end

  until system("git commit -m 'Add empty file as commit'")
    sleep 1
  end

  until system("git checkout -b development master")
    sleep 1
  end

  until system("git checkout master")
    sleep 1
  end

  if (Dir.exists? (File.join(TEST_ROOT, "tmp")))
    Dir.rmdir(File.join(TEST_ROOT, "tmp"))
  end

  Dir.mkdir(File.join(TEST_ROOT, "tmp"), 0777)
  Dir.chdir(File.join(TEST_ROOT, "tmp"))

  # setup the new repository with an empty set this is configured in the config.rb file
  until system("git init")
    sleep 1
  end

  until system("git remote add origin #{File.join(TEST_ROOT, "remote")}")
    sleep 1
  end

  until system("git remote update")
    sleep 1
  end

  until system("git remote set-head origin -a")
    sleep 1
  end

  until system("git checkout -b master origin/master")
    sleep 1
  end
end

Test::Unit.at_exit do
  FileUtils.rm_rf(File.join(TEST_ROOT, "remote"))
  FileUtils.rm_rf(File.join(TEST_ROOT, "tmp"))
end
