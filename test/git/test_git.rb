require 'git/test_git_base'

class GitTest < Test::Unit::TestCase
  def test_get_branch_name
    current_branch = Toolshed::Git::Base.branch_name

    new_branch_name = ::Faker::Lorem.word.downcase
    create_and_checkout_branch(new_branch_name)

    assert_equal new_branch_name, Toolshed::Git::Base.branch_name

    Toolshed::Git::Base.checkout(current_branch)
    pop_stash
    delete_branch(new_branch_name)
  end

  def test_checkout_branch
    Toolshed::Client.use_git_submodules = false
    current_branch = Toolshed::Git::Base.branch_name

    new_branch_name = ::Faker::Lorem.word.downcase
    create_and_checkout_branch(new_branch_name)

    Toolshed::Git::Base.checkout(current_branch)

    assert_equal current_branch, Toolshed::Git::Base.branch_name

    delete_branch(new_branch_name)
  end

  def test_checkout_branch_by_id
    Toolshed::Client.use_git_submodules = false
    current_branch = Toolshed::Git::Base.branch_name

    branch_id = "124233"

    new_branch_name = ::Faker::Lorem.word.downcase
    new_branch_name = "#{branch_id}_#{new_branch_name}"
    create_and_checkout_branch(new_branch_name)

    Toolshed::Git::Base.checkout(current_branch)
    assert_equal current_branch, Toolshed::Git::Base.branch_name

    Toolshed::Git::Base.checkout(branch_id)
    assert_equal new_branch_name, Toolshed::Git::Base.branch_name

    Toolshed::Git::Base.checkout(current_branch)
    delete_branch(new_branch_name)
  end

  def test_branched_from
    current_branch = Toolshed::Git::Base.branch_name
    current_branch_branched_from = Toolshed::Git::Base.branched_from

    new_branch_name = ::Faker::Lorem.word.downcase
    create_and_checkout_branch(new_branch_name, 'development')

    assert_equal 'development', Toolshed::Git::Base.branched_from

    Toolshed::Git::Base.checkout(current_branch)
    delete_branch(new_branch_name)
  end

  def test_create_new_branch
    current_branch = Toolshed::Git::Base.branch_name

    new_branch_name = ::Faker::Lorem.word.downcase
    git = Toolshed::Git::Base.new({
      from_remote_branch_name: 'development',
      to_remote_branch_name: new_branch_name,
      from_remote_name: 'origin',
      to_remote_name: 'origin',
    })
    git.create_branch

    assert_equal new_branch_name, Toolshed::Git::Base.branch_name
    assert_equal 'development', Toolshed::Git::Base.branched_from

    Toolshed::Git::Base.checkout(current_branch)
    delete_branch(new_branch_name)
  end

  def test_create_branch_from_remote_name_empty
    new_branch_name = ::Faker::Lorem.word.downcase
    git = Toolshed::Git::Base.new({
      from_remote_branch_name: '',
      to_remote_branch_name: new_branch_name,
      from_remote_name: 'origin',
      to_remote_name: 'origin',
    })

    exception = assert_raise(Veto::InvalidEntity) { git.create_branch }
    assert_equal 'from_remote_branch_name is not present', exception.message.first
  end
end
