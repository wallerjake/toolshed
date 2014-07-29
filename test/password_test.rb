require 'helper'

class PasswordTest < Test::Unit::TestCase
  def test_read_user_input_password
    password = Toolshed::Password.new({ password: 'test1234' })
    assert_equal password.read_user_input_password('password'), 'test1234'
  end

  def test_read_user_input_password_sudo
    password = Toolshed::Password.new({ sudo_password: 'test12345' })
    assert_equal password.read_user_input_password('sudo_password'), 'test12345'
  end

  def test_read_user_input_password_prompt
    password = Toolshed::Password.new({})
    password.expects(:get_password_input).returns('readin1234')
    assert_equal password.read_user_input_password('password'), 'readin1234'
  end

  def test_read_user_input_from_toolshedrc
    password = Toolshed::Password.new({ password: 'server_password' })
    assert_equal password.read_user_input_password('password'), 'tester1234'
  end
end
