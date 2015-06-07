require 'commands/commands_helper'
require 'toolshed/commands/create_pull_request'
require 'toolshed/git/github'
require 'toolshed/ticket_tracking/pivotal_tracker'

class CreatePullRequestTest < Test::Unit::TestCase
  def setup
    @git = Toolshed::Git.new
    Toolshed.expects(:die).at_least(0).returns('Exiting')
  end

  def test_create_github_pull_request_no_ticket_tracking
    Toolshed::Client.instance.ticket_tracking_tool = ''
    Toolshed::Client.instance.git_tool = 'github'
    Toolshed::Client.instance.github_username = 'sample'
    Toolshed::Client.instance.github_password = 'sample'

    Toolshed::Client.instance.pull_from_repository_user = 'sample'
    Toolshed::Client.instance.pull_from_repository_name = 'sample_repo'

    # mock up the pull request
    expected_result = {
      "html_url" => "github.com/pulls/1",
    }.to_json
    http_mock = mock('Net::HTTPResponse')
    http_mock.stubs(:code => '200', :message => "OK", :content_type => "text/html", :body => expected_result)

    http_party_mock = mock('HTTParty')
    http_party_mock.stubs(:response => http_mock)

    # create new github object
    github = Toolshed::Git::Github.new

    github_default_options = github.default_options
    github_default_options.merge!({
      body: {
        title: 'Sample',
         body: 'Sample Body',
         head: "#{Toolshed::Client.instance.github_username}:#{@git.branch_name}",
         base: Toolshed::Git.branched_from
      }.to_json
    })

    HTTParty.
      expects(:post).
      with("#{Toolshed::Client::GITHUB_BASE_API_URL}repos/#{Toolshed::Client.instance.pull_from_repository_user}/#{Toolshed::Client.instance.pull_from_repository_name}/pulls", github_default_options).
      returns(http_party_mock)

    # stub the possible input
    Toolshed::Commands::CreatePullRequest.any_instance.stubs(:read_user_input_add_note_to_ticket).returns(false)

    result = Toolshed::Commands::CreatePullRequest.new.execute({}, { title: 'Sample', body: 'Sample Body' })
    assert_equal 'github.com/pulls/1', result.pull_request_url
  end

  def test_create_github_pull_request_with_pivotal_tracker
    Toolshed::Client.instance.ticket_tracking_tool = 'pivotal_tracker'
    Toolshed::Client.instance.git_tool = 'github'
    Toolshed::Client.instance.github_username = 'sample'
    Toolshed::Client.instance.github_password = 'sample'
    Toolshed::Client.instance.pivotal_tracker_username = 'ptusername'
    Toolshed::Client.instance.pivotal_tracker_password = 'ptpassword'
    Toolshed::Client.instance.default_pivotal_tracker_project_id = '1234'
    Toolshed::Client.instance.pull_from_repository_user = 'sample'
    Toolshed::Client.instance.pull_from_repository_name = 'sample_repo'
    Toolshed::Client.instance.use_defaults = true

    # mock up the pull request
    expected_result = {
      "html_url" => "github.com/pulls/1",
    }.to_json
    http_mock = mock('Net::HTTPResponse')
    http_mock.stubs(:code => '200', :message => "OK", :content_type => "text/html", :body => expected_result)

    http_party_mock = mock('HTTParty')
    http_party_mock.stubs(:response => http_mock)

    # create new github object
    github = Toolshed::Git::Github.new

    github_default_options = github.default_options
    github_default_options.merge!({
      body: {
        title: 'Sample',
         body: 'Sample Body',
         head: "#{Toolshed::Client.instance.github_username}:#{@git.branch_name}",
         base: Toolshed::Git.branched_from
      }.to_json
    })

    HTTParty.
      expects(:post).
      with("#{Toolshed::Client::GITHUB_BASE_API_URL}repos/#{Toolshed::Client.instance.pull_from_repository_user}/#{Toolshed::Client.instance.pull_from_repository_name}/pulls", github_default_options).
      returns(http_party_mock)

    # mock up the pivotal_tracker stuff
    PivotalTracker::Client.expects(:token).
    with(Toolshed::TicketTracking::PivotalTracker.username, Toolshed::TicketTracking::PivotalTracker.password).
    returns('3454354token')

    # mock up the project response
    pivotal_tracker_mock = mock('PivotalTracker::Client')
    pivotal_tracker_mock.stubs(:id => '1')

    PivotalTracker::Project.expects(:find).
    with(Toolshed::Client.instance.default_pivotal_tracker_project_id).
    returns(pivotal_tracker_mock)

    # mock up the story information
    pivotal_tracker_story_mock = mock('PivotalTracker::Story')
    pivotal_tracker_story_mock.stubs(:url => 'http://www.example.com', :id => '1', :name => "Test Title")

    pivotal_tracker_mock.expects(:stories).
    returns(pivotal_tracker_story_mock)

    pivotal_tracker_story_mock.expects(:find).
    with('1').
    returns(pivotal_tracker_story_mock)

    Toolshed::TicketTracking::PivotalTracker.any_instance.expects(:title).
    returns("Sample")

    Toolshed::TicketTracking::PivotalTracker.any_instance.expects(:url).
    returns("github.com/pulls/1")

    # stub the possible input
    Toolshed::Commands::CreatePullRequest.any_instance.stubs(:read_user_input_ticket_tracker_ticket_id).returns('1')
    Toolshed::Commands::CreatePullRequest.any_instance.stubs(:read_user_input_add_note_to_ticket).returns(false)

    result = Toolshed::Commands::CreatePullRequest.new.execute({}, { title: 'Sample', body: 'Sample Body' })
    assert_equal 'github.com/pulls/1', result.pull_request_url
  end

  def test_create_github_pull_request_with_invalid_ticket_tracker
    Toolshed::Client.instance.ticket_tracking_tool = 'unfuddle'
    Toolshed::Client.instance.git_tool = 'github'
    result = Toolshed::Commands::CreatePullRequest.new.execute({}, { title: 'Sample', body: 'Sample Body' })
    assert_equal nil, result.pull_request_url
  end
end
