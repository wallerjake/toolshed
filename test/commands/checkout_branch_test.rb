require 'commands/commands_helper'
require 'toolshed/commands/checkout_branch'

class CheckoutBranchTest < Test::Unit::TestCase
  def setup
    @git = Toolshed::Git.new
    Toolshed.expects(:die).at_least(0).returns('die')
  end

  def test_checkout_branch
    current_branch = @git.branch_name

    new_branch_name = random_branch_name
    create_and_checkout_branch(new_branch_name)

    results = Toolshed::Commands::CheckoutBranch.new.execute({}, { branch_name: current_branch })
    assert_equal 'die', results
  end

  def test_checkout_branch_prompt
    current_branch = @git.branch_name

    new_branch_name = random_branch_name
    create_and_checkout_branch(new_branch_name)   

    # stub the possible input
    Toolshed::Commands::CheckoutBranch.any_instance.stubs(:read_user_input).returns(current_branch)

    results = Toolshed::Commands::CheckoutBranch.new.execute({})
    assert_equal 'die', results
  end
end
