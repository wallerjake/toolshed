require 'commands/commands_helper'
require 'toolshed/commands/push_branch'

class PushBranchTest < Test::Unit::TestCase
  def test_push_branch_current_working_branch
    Toolshed::Client.push_to_remote_name = 'origin'

    current_branch = Toolshed::Git::Base.branch_name

    new_branch_name = ::Faker::Lorem.word.downcase
    create_and_checkout_branch(new_branch_name, 'master')

    output = capture_stdout { Toolshed::Commands::PushBranch.new.execute({}) }
    assert_match /#{new_branch_name} has been pushed/, output

    Toolshed::Git::Base.checkout(current_branch)
    delete_branch(new_branch_name)
  end

  def test_push_branch_by_ticket_id
    Toolshed::Client.push_to_remote_name = 'origin'

    current_branch = Toolshed::Git::Base.branch_name

    new_branch_name = "555558_#{::Faker::Lorem.word.downcase}"
    create_and_checkout_branch(new_branch_name, 'master')

    output = capture_stdout { Toolshed::Commands::PushBranch.new.execute({}, { branch_name: '555558' }) }
    assert_match /#{new_branch_name} has been pushed/, output

    Toolshed::Git::Base.checkout(current_branch)
    delete_branch(new_branch_name)
  end

  def test_push_branch_current_working_branch_with_force
    Toolshed::Client.push_to_remote_name = 'origin'

    current_branch = Toolshed::Git::Base.branch_name

    new_branch_name = ::Faker::Lorem.word.downcase
    create_and_checkout_branch(new_branch_name, 'master')

    output = capture_stdout { Toolshed::Commands::PushBranch.new.execute({}, { force: true }) }
    assert_match /#{new_branch_name} has been pushed/, output

    Toolshed::Git::Base.checkout(current_branch)
    delete_branch(new_branch_name)
  end
end
