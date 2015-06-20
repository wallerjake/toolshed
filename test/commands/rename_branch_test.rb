require 'commands/commands_helper'
require 'toolshed/commands/rename_branch'

class DeleteBranchTest < Test::Unit::TestCase
  def setup
    Toolshed.expects(:die).at_least(0).returns('Exiting')
    @branch = Toolshed::Git::Branch.new
  end

  def test_with_options_passed_in
    current_branch = @branch.name

    new_branch_name = random_branch_name
    create_and_checkout_branch(new_branch_name, 'master')

    # go to the remote repo and verify it exists
    Dir.chdir(File.join(TEST_ROOT, "remote"))
    remote_current_branch = @branch.name
    Toolshed::Git::Branch.checkout(new_branch_name)
    assert_equal new_branch_name, @branch.name
    Toolshed::Git::Branch.checkout(remote_current_branch)

    Dir.chdir(File.join(TEST_ROOT, "local"))
    Toolshed::Git::Branch.checkout(current_branch)

    rename_branch_command = Toolshed::Commands::RenameBranch.new
    result = rename_branch_command.execute({}, branch_name: new_branch_name, new_branch_name: 'testing_command')
    assert_equal 'Exiting', result

    branch_found = `git branch | grep #{new_branch_name}`
    assert_equal '', branch_found
  end

  def test_without_passing_in_options
    current_branch = @branch.name

    new_branch_name = random_branch_name
    create_and_checkout_branch(new_branch_name, 'master')

    # go to the remote repo and verify it exists
    Dir.chdir(File.join(TEST_ROOT, "remote"))
    remote_current_branch = @branch.name
    Toolshed::Git::Branch.checkout(new_branch_name)
    assert_equal new_branch_name, @branch.name
    Toolshed::Git::Branch.checkout(remote_current_branch)

    Dir.chdir(File.join(TEST_ROOT, "local"))
    Toolshed::Git::Branch.checkout(current_branch)

    rename_branch_command = Toolshed::Commands::RenameBranch.new
    rename_branch_command.expects(:read_user_input).with('Branch name?', required: true).returns(new_branch_name)
    rename_branch_command.expects(:read_user_input).with('New Branch name?', required: true).returns('testing_command_no_options')
    result = rename_branch_command.execute({})
    assert_equal 'Exiting', result

    branch_found = `git branch | grep #{new_branch_name}`
    assert_equal '', branch_found
  end
end
