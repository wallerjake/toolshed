require 'commands/commands_helper'
require 'toolshed/commands/create_branch'

class CreateBranchTest < Test::Unit::TestCase
  def test_create_new_branch_passing_in_branch_name_branch_from
    Toolshed::Client.instance.pull_from_remote_name = 'origin'
    Toolshed::Client.instance.push_to_remote_name = 'origin'

    current_branch = Toolshed::Git::Base.branch_name
    new_branch_name = ::Faker::Lorem.word.downcase

    output = capture_stdout { Toolshed::Commands::CreateBranch.new.execute({}, { branch_name: new_branch_name, branch_from: 'development' }) }

    assert_match /Branch #{new_branch_name} has been created/, output

    assert_equal new_branch_name, Toolshed::Git::Base.branch_name
    assert_equal 'development', Toolshed::Git::Base.branched_from

    Toolshed::Git::Base.checkout(current_branch)
    delete_branch(new_branch_name)
  end

  def test_create_new_branch_not_passing_in_branch_name_or_branch_from
    Toolshed::Client.instance.pull_from_remote_name = 'origin'
    Toolshed::Client.instance.push_to_remote_name = 'origin'

    current_branch = Toolshed::Git::Base.branch_name
    new_branch_name = ::Faker::Lorem.word.downcase

    # stub the possible input
    Toolshed::Commands::CreateBranch.any_instance.stubs(:read_user_input_branch_name).returns(new_branch_name)
    Toolshed::Commands::CreateBranch.any_instance.stubs(:read_user_input_branch_from).returns('development')

    output = capture_stdout { Toolshed::Commands::CreateBranch.new.execute({}) }

    assert_match /Branch #{new_branch_name} has been created/, output

    assert_equal new_branch_name, Toolshed::Git::Base.branch_name
    assert_equal 'development', Toolshed::Git::Base.branched_from

    Toolshed::Git::Base.checkout(current_branch)
    delete_branch(new_branch_name)
  end

  def test_create_new_branch_without_passing_in_branch_from
    Toolshed::Client.instance.pull_from_remote_name = 'origin'
    Toolshed::Client.instance.push_to_remote_name = 'origin'

    current_branch = Toolshed::Git::Base.branch_name
    new_branch_name = ::Faker::Lorem.word.downcase

    # stub the possible input
    Toolshed::Commands::CreateBranch.any_instance.stubs(:read_user_input_branch_name).returns(new_branch_name)

    output = capture_stdout { Toolshed::Commands::CreateBranch.new.execute({}, { branch_name: new_branch_name }) }

    assert_match /Branch #{new_branch_name} has been created/, output
    assert_equal new_branch_name, Toolshed::Git::Base.branch_name
    assert_equal 'master', Toolshed::Git::Base.branched_from

    Toolshed::Git::Base.checkout(current_branch)
    delete_branch(new_branch_name)
  end
end
