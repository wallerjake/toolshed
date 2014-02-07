require 'git/test_git_base'

class GitTest < Test::Unit::TestCase
  def test_get_branch_name
    Toolshed::Client.use_git_submodules = false
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
    #Toolshed::Client.use_git_submodules = false
    #current_branch = Toolshed::Git::Base.branch_name
    #current_branch_branched_from = Toolshed::Git::Base.branched_from
  end
end
