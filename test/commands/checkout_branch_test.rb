require 'commands/commands_base'
require 'toolshed/commands/checkout_branch'

class CheckoutBranchTest < Test::Unit::TestCase
  def test_checkout_branch
    current_branch = Toolshed::Git::Base.branch_name

    new_branch_name = ::Faker::Lorem.word.downcase
    create_and_checkout_branch(new_branch_name)   

    output = capture_stdout { Toolshed::Commands::CheckoutBranch.new.execute({}, { branch_name: current_branch }) }

    assert_match /Switched to 'master'/, output
  end

  def test_checkout_branch_prompt
    current_branch = Toolshed::Git::Base.branch_name

    new_branch_name = ::Faker::Lorem.word.downcase
    create_and_checkout_branch(new_branch_name)   

    # stub the possible input
    Toolshed::Commands::CheckoutBranch.any_instance.stubs(:read_user_input).returns(current_branch)

    output = capture_stdout { Toolshed::Commands::CheckoutBranch.new.execute({}) }
    assert_match /Switched to 'master'/, output
  end
end
