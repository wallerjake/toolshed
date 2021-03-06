require 'commands/commands_helper'
require 'toolshed/commands/push_branch'

class PushBranchTest < Test::Unit::TestCase
  def setup
    Toolshed.expects(:die).at_least(0).returns('Exiting')
    @branch = Toolshed::Git::Branch.new
  end

  def test_push_branch_current_working_branch
    Toolshed::Client.instance.push_to_remote_name = 'origin'

    current_branch = Toolshed::Git::Branch.name

    new_branch_name = random_branch_name
    create_and_checkout_branch(new_branch_name, 'master')

    push_branch_command = Toolshed::Commands::PushBranch.new
    push_branch_command.execute({})

    assert_equal new_branch_name, @branch.name

    Toolshed::Git::Branch.checkout(current_branch)
    delete_branch(new_branch_name)
  end

  def test_push_branch_by_ticket_id
    Toolshed::Client.instance.push_to_remote_name = 'origin'

    current_branch = @branch.name

    new_branch_name = "555558_#{random_branch_name}"
    create_and_checkout_branch(new_branch_name, 'master')

    push_branch_command = Toolshed::Commands::PushBranch.new

    expected_git = Toolshed::Git::Branch.new(branch_name: '555558')
    push_branch_command.execute({}, { branch_name: '555558' })
    assert_equal new_branch_name, expected_git.name

    Toolshed::Git::Branch.checkout(current_branch)
    delete_branch(new_branch_name)
  end

  def test_push_branch_current_working_branch_with_force
    Toolshed::Client.instance.push_to_remote_name = 'origin'

    current_branch = Toolshed::Git::Branch.name

    new_branch_name = random_branch_name
    create_and_checkout_branch(new_branch_name, 'master')

    push_branch_command = Toolshed::Commands::PushBranch.new
    push_branch_command.execute({}, { force: true })

    assert_equal new_branch_name, @branch.name

    Toolshed::Git::Branch.checkout(current_branch)
    delete_branch(new_branch_name)
  end
end
