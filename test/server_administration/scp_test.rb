require 'commands/commands_helper'
require 'toolshed/commands/scp/download'
require 'net/scp'

module Test
  module ServerAdministration
    class SCPTest < Test::Unit::TestCase
      def setup
        Toolshed::Logger.instance.instance_variable_set(:@logs, { debug: [], fatal: [], info: [], warn: [] })
      end

      def teardown
        Toolshed::Logger.instance.instance_variable_set(:@logs, { debug: [], fatal: [], info: [], warn: [] })
      end

      def test_scp_download
        Net::SCP.expects(:download!).returns('downloaded')

        scp = Toolshed::ServerAdministration::SCP.new(password: 'test1234', username: 'test', remote_host: 'localhost', remote_path: '/tmp', local_path: '/tmp')
        scp.download

        assert Toolshed::Logger.instance.logs[:info].include?('SCP file transfer has completed.')
        assert Toolshed::Logger.instance.logs[:info].include?('Attempting to SCP from test@localhost:/tmp to /tmp.')
      end

      def test_scp_upload
        Net::SCP.expects(:upload!).returns('uploaded')

        scp = Toolshed::ServerAdministration::SCP.new(password: 'test1234', username: 'test', remote_host: 'localhost', remote_path: '/tmp', local_path: '/tmp')
        scp.upload

        assert Toolshed::Logger.instance.logs[:info].include?('SCP file transfer has completed.')
        assert Toolshed::Logger.instance.logs[:info].include?('Attempting to SCP from /tmp to test@localhost:/tmp.')
      end
    end
  end
end
