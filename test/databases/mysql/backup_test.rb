require 'commands/commands_helper'
require 'toolshed/databases/mysql/backup'

module Test
  module Databases
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
          Toolshed::Base.expects(:wait_for_command).returns({})

          path = '/tmp/testing/test.sql'
          username = 'test'
          password = 'test'
          name = 'localdb'

          Toolshed::Databases::Mysql::Backup.new(path: path, username: username, password: password, name: name, host: 'localhost').execute

          assert Toolshed::Logger.instance.logs[:info].include?("Starting execution of mysqldump -h localhost -u #{username} -p ******* #{name} > #{path}.")
          assert Toolshed::Logger.instance.logs[:info].include?('mysqldump has completed.')
        end

        def test_raises_type_error_if_wait_time_is_not_a_fixnum
          path = '/tmp/testing/test.sql'
          username = 'test'
          password = 'test'
          name = 'localdb'

          ex = assert_raises TypeError do
            Toolshed::Databases::Mysql::Backup.new(path: path, username: username, password: password, name: name, host: 'localhost', wait_time: 'bla').execute
          end
          assert_equal 'Wait time passed in is not a number bla', ex.message
        end
      end
    end
  end
end
