require 'git/test_git_base'

class GitTest < Test::Unit::TestCase
  def test_get_branch_name
    Toolshed::Client.use_git_submodules = false

    current_branch = Toolshed::Git.branch_name

    new_branch_name = ::Faker::Lorem.word.downcase
    create_and_checkout_branch(new_branch_name)

    assert_equal new_branch_name, Toolshed::Git.branch_name

    Toolshed::Git.checkout(current_branch)
    pop_stash

    db = `git branch -D #{new_branch_name}`
  end
end
