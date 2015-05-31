require 'commands/commands_helper'
require 'toolshed/commands/delete_branch'

class DeleteBranchTest < Test::Unit::TestCase
  def setup
    Toolshed.expects(:die).at_least(0).returns('Exiting')
    @git = Toolshed::Git::Base.new
  end

  def test_delete_branch_with_branch_name_passed
    current_branch = @git.branch_name

    new_branch_name = random_branch_name
    create_and_checkout_branch(new_branch_name, 'master')

    # go to the remote repo and verify it exists
    Dir.chdir(File.join(TEST_ROOT, "remote"))
    remote_current_branch = @git.branch_name
    Toolshed::Git::Base.checkout_branch(new_branch_name)
    assert_equal new_branch_name, @git.branch_name
    Toolshed::Git::Base.checkout_branch(remote_current_branch)

    Dir.chdir(File.join(TEST_ROOT, "local"))
    Toolshed::Git::Base.checkout_branch(current_branch)

    result = Toolshed::Commands::DeleteBranch.new.execute({}, { branch_name: new_branch_name })
    assert_equal 'Exiting', result

    branch_found = `git branch | grep #{new_branch_name}`
    assert_equal '', branch_found
  end

  def test_delete_branch_with_ticket_id_only_passed
    current_branch = @git.branch_name

    new_branch_name = "1234333_#{random_branch_name}"
    create_and_checkout_branch(new_branch_name, 'master')

    # go to the remote repo and verify it exists
    Dir.chdir(File.join(TEST_ROOT, "remote"))
    remote_current_branch = @git.branch_name
    Toolshed::Git::Base.checkout_branch(new_branch_name)
    assert_equal new_branch_name, @git.branch_name
    Toolshed::Git::Base.checkout_branch(remote_current_branch)

    Dir.chdir(File.join(TEST_ROOT, "local"))
    Toolshed::Git::Base.checkout_branch(current_branch)
    result = Toolshed::Commands::DeleteBranch.new.execute({}, { branch_name: '1234333' })
    assert_equal 'Exiting', result

    branch_found = `git branch | grep #{new_branch_name}`
    assert_equal '', branch_found
  end

  def test_delete_branch_without_branch_name_passed
    current_branch = @git.branch_name

    new_branch_name = random_branch_name
    create_and_checkout_branch(new_branch_name, 'master')

    # go to the remote repo and verify it exists
    Dir.chdir(File.join(TEST_ROOT, "remote"))
    remote_current_branch = @git.branch_name
    Toolshed::Git::Base.checkout_branch(new_branch_name)
    assert_equal new_branch_name, @git.branch_name
    Toolshed::Git::Base.checkout_branch(remote_current_branch)

    Dir.chdir(File.join(TEST_ROOT, "local"))
    Toolshed::Git::Base.checkout_branch(current_branch)

    Toolshed::Commands::DeleteBranch.any_instance.stubs(:read_user_input).returns(new_branch_name)

    result = Toolshed::Commands::DeleteBranch.new.execute({})
    assert_equal 'Exiting', result

    branch_found = `git branch | grep #{new_branch_name}`
    assert_equal '', branch_found
  end
end
