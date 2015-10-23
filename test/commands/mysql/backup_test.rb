require 'commands/commands_helper'
require 'toolshed/commands/mysql/backup'

module Test
  module Commands
    module Mysql
      class BackupTest < Test::Unit::TestCase
        def setup
          Toolshed::Logger.instance.instance_variable_set(:@logs, { debug: [], fatal: [], info: [], warn: [] })
          Toolshed.expects(:die).at_least(0).returns('Exiting')
        end

        def teardown
          Toolshed::Logger.instance.instance_variable_set(:@logs, { debug: [], fatal: [], info: [], warn: [] })
        end

        def test_execute
          Toolshed::Base.expects(:wait_for_command).returns(true)

          path = '/tmp/testing/test.sql'
          username = 'test'
          password = 'test'
          name = 'localdb'

          mysql_backup_command = Toolshed::Commands::Mysql::Backup.new
          mysql_backup_command.execute({}, path: path, username: username, password: password, name: name)

          assert Toolshed::Logger.instance.logs[:info].include?("Starting execution of mysqldump -h localhost -u #{username} -p ******* #{name} > #{path}.")
          assert Toolshed::Logger.instance.logs[:info].include?('mysqldump has completed.')
        end

        def test_cli_options
          assert 'Usage: mysql backup [options]', Toolshed::Commands::Mysql::Backup.cli_options[:banner]
        end
      end
    end
  end
end
