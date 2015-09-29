require 'commands/commands_helper'
require 'toolshed/commands/scp/download'
require 'net/scp'

module Test
  module Commands
    module SCP
      class DownloadTest < Test::Unit::TestCase
        def setup
          Toolshed::Logger.instance.instance_variable_set(:@logs, { debug: [], fatal: [], info: [], warn: [] })
          Toolshed.expects(:die).at_least(0).returns('Exiting')
        end

        def teardown
          Toolshed::Logger.instance.instance_variable_set(:@logs, { debug: [], fatal: [], info: [], warn: [] })
        end

        def test_scp_upload
          Net::SCP.expects(:download!).returns('downloaded')

          scp_download_command = Toolshed::Commands::SCP::Download.new
          scp_download_command.execute({}, password: 'test1234', username: 'test', remote_host: 'localhost', remote_path: '/tmp', local_path: '/tmp')

          assert Toolshed::Logger.instance.logs[:info].include?('SCP file transfer has completed.')
          assert Toolshed::Logger.instance.logs[:info].include?('Attempting to SCP from test@localhost:/tmp to /tmp.')
        end

        def test_cli_options
          assert 'Usage: scp download [options]', Toolshed::Commands::SCP::Download.cli_options[:banner]
        end
      end
    end
  end
end
