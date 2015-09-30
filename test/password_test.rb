require 'helper'
require 'toolshed/server_administration/scp'

class PasswordTest < Test::Unit::TestCase
  def test_password_from_config
    expected_password = 'tester1234'
    actual_password = Toolshed::ServerAdministration::SCP.new({}).password_from_config('server_password')
    assert_equal expected_password, actual_password
  end
end
