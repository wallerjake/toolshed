require 'config'
require 'simplecov'

if (ENV["COVERAGE"])
  SimpleCov.start do
    add_filter 'test/'
  end
end

require 'test/unit'
require 'mocha/test_unit'
require 'faker'
require 'veto'
require 'fileutils'
require 'json'

require 'toolshed'

Test::Unit.at_start do
  Toolshed::Client.use_git_submodules = false
  #Toolshed::Client.git_quiet = '&> /dev/null' unless ENV['RUNNING_ON_CI']
  Toolshed::Client.git_quiet = ''

  I18n.config.enforce_available_locales = true

  FileUtils.rm_rf(File.join(TEST_ROOT, "remote"))
  FileUtils.rm_rf(File.join(TEST_ROOT, "local"))

  # setup a fake remote directory so we can reference everything locally
  if (Dir.exists? (File.join(TEST_ROOT, "remote")))
    Dir.rmdir(File.join(TEST_ROOT, "remote"))
  end

  Dir.mkdir(File.join(TEST_ROOT, "remote"), 0777)
  Dir.chdir(File.join(TEST_ROOT, "remote"))

  # setup a couple of branches acting as the remote repository
  until system("git init #{Toolshed::Client.git_quiet}")
    sleep 1
  end

  FileUtils.touch('file.txt')

  until system("git add file.txt #{Toolshed::Client.git_quiet}")
    sleep 1
  end

  until system("git commit -m 'Add empty file as commit' #{Toolshed::Client.git_quiet}")
    sleep 1
  end

  until system("git checkout -b development master #{Toolshed::Client.git_quiet}")
    sleep 1
  end

  until system("git checkout master #{Toolshed::Client.git_quiet}")
    sleep 1
  end

  if (Dir.exists? (File.join(TEST_ROOT, "local")))
    Dir.rmdir(File.join(TEST_ROOT, "local"))
  end

  Dir.mkdir(File.join(TEST_ROOT, "local"), 0777)
  Dir.chdir(File.join(TEST_ROOT, "local"))

  # setup the new repository with an empty set this is configured in the config.rb file
  until system("git init #{Toolshed::Client.git_quiet}")
    sleep 1
  end

  until system("git remote add origin #{File.join(TEST_ROOT, "remote")} #{Toolshed::Client.git_quiet}")
    sleep 1
  end

  until system("git remote update #{Toolshed::Client.git_quiet}")
    sleep 1
  end

  until system("git checkout -b master origin/master #{Toolshed::Client.git_quiet}")
    sleep 1
  end
end

Test::Unit.at_exit do
  FileUtils.rm_rf(File.join(TEST_ROOT, "remote"))
  FileUtils.rm_rf(File.join(TEST_ROOT, "local"))
end

def capture_stdout(&block)
  original_stdout = $stdout
  $stdout = fake = StringIO.new
  begin
    yield
  ensure
    $stdout = original_stdout
  end
  fake.string
end
