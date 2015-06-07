require 'helper'
require 'toolshed/server_administration/ssh'

class SSHTest < Test::Unit::TestCase
  def test_setting_ssh_options
    ssh = Toolshed::ServerAdministration::SSH.new({ keys: 'testing1234' })
    assert_equal Set.new(ssh.ssh_options), Set.new({ keys: ['testing1234'] })
  end

  def test_execute
    params = { keys: 'testing1234', host: 'localhost', user: 'localhost' }

    net_ssh_connection_mock = mock('Net::SSH::Connection::Session')
    net_ssh_connection_mock.stubs({ connection: true })

    net_ssh_connection_channel_mock = mock('Net::SSH::Connection::Channel')
    net_ssh_connection_channel_mock.stubs({ request_pty: [net_ssh_connection_mock, 'good'] })

    Net::SSH.expects(:start).with(params[:host], params[:user], { keys: [params[:keys]] }).returns(net_ssh_connection_mock)

    ssh = Toolshed::ServerAdministration::SSH.new(params)
    ssh.execute
  end
end
