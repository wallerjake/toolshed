require 'commands/commands_helper'
require 'toolshed/commands/create_branch'

class CreateBranchTest < Test::Unit::TestCase
  def setup
    @git = Toolshed::Git::Base.new
    Toolshed.expects(:die).at_least(0).returns('die')
  end

  def test_create_new_branch_passing_in_branch_name_branch_from
    Toolshed::Client.instance.pull_from_remote_name = 'origin'
    Toolshed::Client.instance.push_to_remote_name = 'origin'

    current_branch = @git.branch_name
    new_branch_name = ::Faker::Lorem.word.downcase

    output = Toolshed::Commands::CreateBranch.new.execute({}, { branch_name: new_branch_name, branch_from: 'development' })

    assert_match 'die', output

    assert_equal new_branch_name, @git.branch_name
    assert_equal 'development', Toolshed::Git::Base.branched_from

    Toolshed::Git::Base.checkout_branch(current_branch)
    delete_branch(new_branch_name)
  end

  def test_create_new_branch_not_passing_in_branch_name_or_branch_from
    Toolshed::Client.instance.pull_from_remote_name = 'origin'
    Toolshed::Client.instance.push_to_remote_name = 'origin'

    current_branch = @git.branch_name
    new_branch_name = ::Faker::Lorem.word.downcase

    # stub the possible input
    Toolshed::Commands::CreateBranch.any_instance.stubs(:read_user_input_branch_name).returns(new_branch_name)
    Toolshed::Commands::CreateBranch.any_instance.stubs(:read_user_input_branch_from).returns('development')

    output = Toolshed::Commands::CreateBranch.new.execute({})

    assert_match 'die', output

    assert_equal new_branch_name, @git.branch_name
    assert_equal 'development', Toolshed::Git::Base.branched_from

    Toolshed::Git::Base.checkout_branch(current_branch)
    delete_branch(new_branch_name)
  end

  def test_create_new_branch_without_passing_in_branch_from
    Toolshed::Client.instance.pull_from_remote_name = 'origin'
    Toolshed::Client.instance.push_to_remote_name = 'origin'

    current_branch = @git.branch_name
    new_branch_name = ::Faker::Lorem.word.downcase

    # stub the possible input
    Toolshed::Commands::CreateBranch.any_instance.stubs(:read_user_input_branch_name).returns(new_branch_name)

    output = Toolshed::Commands::CreateBranch.new.execute({}, { branch_name: new_branch_name })

    assert_match 'die', output
    assert_equal new_branch_name, @git.branch_name
    assert_equal 'master', Toolshed::Git::Base.branched_from

    Toolshed::Git::Base.checkout_branch(current_branch)
    delete_branch(new_branch_name)
  end
end
