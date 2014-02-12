require 'git/test_git_base'

class GitHubTest < Test::Unit::TestCase
  def test_list_branches
    Toolshed::Client.github_username = 'sample'
    Toolshed::Client.pull_from_repository_name = 'sample'

    expected_result = [
      {
        "name" => "master",
        "commit" => {
          "sha" => "6dcb09b5b57875f334f61aebed695e2e4193db5e",
          "url" => "https://api.github.com/repos/octocat/Hello-World/commits/c5b97d5ae6c19d5c5df71a34c7fbeeda2479ccbc"
        }
      },
      {
        "name" => "develop",
        "commit" => {
          "sha" => "6dcb09b5b57875f334f61aebed695e2e4193db5e",
          "url" => "https://api.github.com/repos/octocat/Hello-World/commits/345lj5ae6c19d5c5df71a34c7fbeeda2479ccbc"
        }
      }
    ].to_json
    http_mock = mock('Net::HTTPResponse')
    http_mock.stubs(:code => '200', :message => "OK", :content_type => "text/html", :body => expected_result)

    http_party_mock = mock('HTTParty')
    http_party_mock.stubs(:response => http_mock)

    # create new github object
    github = Toolshed::Git::Github.new

    HTTParty.
      expects(:get).
      with("#{Toolshed::Client::GITHUB_BASE_API_URL}repos/#{Toolshed::Client.github_username}/#{Toolshed::Client.pull_from_repository_name}/branches", github.default_options).
      returns(http_party_mock)

    assert_equal JSON.parse(expected_result), github.list_branches
  end

  def test_create_pull_request
    current_branch = Toolshed::Git::Base.branch_name
    new_branch_name = '1234_testing'

    Toolshed::Client.pull_from_repository_user = 'sample'
    Toolshed::Client.pull_from_repository_name = 'sample_repo'
    create_and_checkout_branch(new_branch_name)

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
         head: "#{Toolshed::Client.github_username}:#{Toolshed::Git::Base.branch_name}",
         base: Toolshed::Git::Base.branched_from
      }.to_json
    })

    HTTParty.
      expects(:post).
      with("#{Toolshed::Client::GITHUB_BASE_API_URL}repos/#{Toolshed::Client.pull_from_repository_user}/#{Toolshed::Client.pull_from_repository_name}/pulls", github_default_options).
      returns(http_party_mock)

    assert_equal JSON.parse(expected_result), github.create_pull_request('Sample', 'Sample Body')

    Toolshed::Git::Base.checkout(current_branch)
    delete_branch(new_branch_name)
  end
end
