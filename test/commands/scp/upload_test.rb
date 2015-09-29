require 'commands/commands_helper'
require 'toolshed/commands/scp/upload'
require 'net/scp'

module Test
  module Commands
    module SCP
      class UploadTest < Test::Unit::TestCase
        def setup
          Toolshed::Logger.instance.instance_variable_set(:@logs, { debug: [], fatal: [], info: [], warn: [] })
          Toolshed.expects(:die).at_least(0).returns('Exiting')
        end

        def teardown
          Toolshed::Logger.instance.instance_variable_set(:@logs, { debug: [], fatal: [], info: [], warn: [] })
        end

        def test_scp_upload
          Net::SCP.expects(:upload!).returns('uploaded')

          scp_upload_command = Toolshed::Commands::SCP::Upload.new
          scp_upload_command.execute({}, password: 'test1234', username: 'test', remote_host: 'localhost', remote_path: '/tmp', local_path: '/tmp')

          assert Toolshed::Logger.instance.logs[:info].include?('SCP file transfer has completed.')
          assert Toolshed::Logger.instance.logs[:info].include?('Attempting to SCP from /tmp to test@localhost:/tmp.')
        end

        def test_cli_options
          assert 'Usage: scp upload [options]', Toolshed::Commands::SCP::Upload.cli_options[:banner]
        end
      end
    end
  end
end
