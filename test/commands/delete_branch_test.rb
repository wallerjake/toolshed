require 'commands/commands_helper'
require 'toolshed/commands/delete_branch'

class DeleteBranchTest < Test::Unit::TestCase
  def test_delete_branch_with_branch_name_passed
    current_branch = Toolshed::Git::Base.branch_name

    new_branch_name = ::Faker::Lorem.word.downcase
    create_and_checkout_branch(new_branch_name, 'master')

    # go to the remote repo and verify it exists
    Dir.chdir(File.join(TEST_ROOT, "remote"))
    remote_current_branch = Toolshed::Git::Base.branch_name
    Toolshed::Git::Base.checkout(new_branch_name)
    assert_equal new_branch_name, Toolshed::Git::Base.branch_name
    Toolshed::Git::Base.checkout(remote_current_branch)

    Dir.chdir(File.join(TEST_ROOT, "local"))
    Toolshed::Git::Base.checkout(current_branch)

    output = capture_stdout { Toolshed::Commands::DeleteBranch.new.execute({}, { branch_name: new_branch_name }) }
    assert_match /#{new_branch_name} has been deleted/, output

    branch_found = `git branch | grep #{new_branch_name}`
    assert_equal '', branch_found
  end

  def test_delete_branch_with_ticket_id_only_passed
    current_branch = Toolshed::Git::Base.branch_name

    new_branch_name = "1234333_#{::Faker::Lorem.word.downcase}"
    create_and_checkout_branch(new_branch_name, 'master')

    # go to the remote repo and verify it exists
    Dir.chdir(File.join(TEST_ROOT, "remote"))
    remote_current_branch = Toolshed::Git::Base.branch_name
    Toolshed::Git::Base.checkout(new_branch_name)
    assert_equal new_branch_name, Toolshed::Git::Base.branch_name
    Toolshed::Git::Base.checkout(remote_current_branch)

    Dir.chdir(File.join(TEST_ROOT, "local"))
    Toolshed::Git::Base.checkout(current_branch)

    output = capture_stdout { Toolshed::Commands::DeleteBranch.new.execute({}, { branch_name: '1234333' }) }
    assert_match /#{new_branch_name} has been deleted/, output

    branch_found = `git branch | grep #{new_branch_name}`
    assert_equal '', branch_found
  end

  def test_delete_branch_without_branch_name_passed
    current_branch = Toolshed::Git::Base.branch_name

    new_branch_name = ::Faker::Lorem.word.downcase
    create_and_checkout_branch(new_branch_name, 'master')

    # go to the remote repo and verify it exists
    Dir.chdir(File.join(TEST_ROOT, "remote"))
    remote_current_branch = Toolshed::Git::Base.branch_name
    Toolshed::Git::Base.checkout(new_branch_name)
    assert_equal new_branch_name, Toolshed::Git::Base.branch_name
    Toolshed::Git::Base.checkout(remote_current_branch)

    Dir.chdir(File.join(TEST_ROOT, "local"))
    Toolshed::Git::Base.checkout(current_branch)

    Toolshed::Commands::DeleteBranch.any_instance.stubs(:read_user_input).returns(new_branch_name)

    output = capture_stdout { Toolshed::Commands::DeleteBranch.new.execute({}) }
    assert_match /#{new_branch_name} has been deleted/, output

    branch_found = `git branch | grep #{new_branch_name}`
    assert_equal '', branch_found
  end
end
