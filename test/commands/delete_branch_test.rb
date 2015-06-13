require 'commands/commands_helper'
require 'toolshed/commands/delete_branch'

class DeleteBranchTest < Test::Unit::TestCase
  def setup
    Toolshed.expects(:die).at_least(0).returns('Exiting')
    @branch = Toolshed::Git::Branch.new
  end

  def test_delete_branch_with_branch_name_passed
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

    delete_branch_command = Toolshed::Commands::DeleteBranch.new
    delete_branch_command.expects(:confirm_delete).returns(true)
    result = delete_branch_command.execute({}, { branch_name: new_branch_name })
    assert_equal 'Exiting', result

    branch_found = `git branch | grep #{new_branch_name}`
    assert_equal '', branch_found
  end

  def test_delete_branch_with_ticket_id_only_passed
    current_branch = @branch.name

    new_branch_name = "1234333_#{random_branch_name}"
    create_and_checkout_branch(new_branch_name, 'master')

    # go to the remote repo and verify it exists
    Dir.chdir(File.join(TEST_ROOT, "remote"))
    remote_current_branch = @branch.name
    Toolshed::Git::Branch.checkout(new_branch_name)
    assert_equal new_branch_name, @branch.name
    Toolshed::Git::Branch.checkout(remote_current_branch)

    Dir.chdir(File.join(TEST_ROOT, "local"))
    Toolshed::Git::Branch.checkout(current_branch)
    delete_branch_command = Toolshed::Commands::DeleteBranch.new
    delete_branch_command.expects(:confirm_delete).returns(true)
    result = delete_branch_command.execute({}, { branch_name: '1234333' })
    assert_equal 'Exiting', result

    branch_found = `git branch | grep #{new_branch_name}`
    assert_equal '', branch_found
  end

  def test_delete_branch_without_branch_name_passed
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

    Toolshed::Commands::DeleteBranch.any_instance.stubs(:read_user_input).returns(new_branch_name)

    delete_branch_command = Toolshed::Commands::DeleteBranch.new
    delete_branch_command.expects(:confirm_delete).returns(true)
    result = delete_branch_command.execute({})
    assert_equal 'Exiting', result

    branch_found = `git branch | grep #{new_branch_name}`
    assert_equal '', branch_found
  end
end
