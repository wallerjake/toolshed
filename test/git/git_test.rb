require 'git/git_helper'

class GitTest < Test::Unit::TestCase
  def setup
    Toolshed.expects(:die).at_least(0).returns('Exiting')
    @branch = Toolshed::Git::Branch.new
  end

  def test_get_branch_name
    current_branch = Toolshed::Git::Branch.name

    new_branch_name = random_branch_name
    create_and_checkout_branch(new_branch_name)

    assert_equal new_branch_name, Toolshed::Git::Branch.name

    Toolshed::Git::Branch.checkout(current_branch)
    pop_stash
    delete_branch(new_branch_name)
  end

  def test_checkout_branch
    current_branch = Toolshed::Git::Branch.name

    new_branch_name = random_branch_name
    create_and_checkout_branch(new_branch_name)

    Toolshed::Git::Branch.checkout(current_branch)

    assert_equal current_branch, Toolshed::Git::Branch.name

    delete_branch(new_branch_name)
  end

  def test_checkout_branch_by_id
    current_branch = Toolshed::Git::Branch.name

    branch_id = "124233"

    new_branch_name = random_branch_name
    new_branch_name = "#{branch_id}_#{new_branch_name}"
    create_and_checkout_branch(new_branch_name)

    Toolshed::Git::Branch.checkout(current_branch)
    assert_equal current_branch, Toolshed::Git::Branch.name

    Toolshed::Git::Branch.checkout(branch_id)
    assert_equal new_branch_name, Toolshed::Git::Branch.name

    Toolshed::Git::Branch.checkout(current_branch)
    delete_branch(new_branch_name)
  end

  def test_branched_from
    current_branch = Toolshed::Git::Branch.name
    current_branch_branched_from = Toolshed::Git::Branch.from

    new_branch_name = random_branch_name
    create_and_checkout_branch(new_branch_name, 'development')

    assert_equal 'development', Toolshed::Git::Branch.from

    Toolshed::Git::Branch.checkout(current_branch)
    delete_branch(new_branch_name)
  end

  def test_create_new_branch
    current_branch = Toolshed::Git::Branch.name

    new_branch_name = random_branch_name
    git_branch = Toolshed::Git::Branch.new({
      from_remote_branch_name: 'development',
      to_remote_branch_name: new_branch_name,
      from_remote_name: 'origin',
      to_remote_name: 'origin',
    })
    git_branch.create

    assert_equal new_branch_name, Toolshed::Git::Branch.name
    assert_equal 'development', Toolshed::Git::Branch.from

    Toolshed::Git::Branch.checkout(current_branch)
    delete_branch(new_branch_name)
  end

  def test_create_branch_from_remote_name_empty
    new_branch_name = random_branch_name
    branch = Toolshed::Git::Branch.new({
      from_remote_branch_name: '',
      to_remote_branch_name: new_branch_name,
      from_remote_name: 'origin',
      to_remote_name: 'origin',
    })

    exception = assert_raise(Veto::InvalidEntity) { branch.create }
    assert_equal 'from_remote_branch_name is not present', exception.message.first
  end

  def test_delete_branch
    current_branch = Toolshed::Git::Branch.name

    new_branch_name = random_branch_name
    create_and_checkout_branch(new_branch_name, 'master')

    # go to the remote repo and verify it exists
    Dir.chdir(File.join(TEST_ROOT, "remote"))
    remote_current_branch = Toolshed::Git::Branch.name
    Toolshed::Git::Branch.checkout(new_branch_name)
    assert_equal new_branch_name, Toolshed::Git::Branch.name
    Toolshed::Git::Branch.checkout(remote_current_branch)

    Dir.chdir(File.join(TEST_ROOT, "local"))
    Toolshed::Git::Branch.checkout(current_branch)

    @branch.delete(new_branch_name)

    branch_found = `git branch | grep #{new_branch_name}`
    assert_equal '', branch_found
  end
end
