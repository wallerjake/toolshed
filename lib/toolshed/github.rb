module Toolshed
  class Github
    include HTTParty

    def initialize(options={})
      @auth = { username: Toolshed::Client::github_username, password: Toolshed::Client::github_password }
      @default_options = {
        :headers => {
            "User-Agent" => "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_8_2) AppleWebKit/537.17 (KHTML, like Gecko) Chrome/24.0.1309.0 Safari/537.17"
        },
        basic_auth: @auth,
      }
    end

    def create_pull_request(title, body, options={})
      options.merge!(@default_options)
      options.merge!({
        body: {
          title: title,
           body: body,
           head: "#{Toolshed::Client.github_username}:#{self.branch_name}",
           base: self.branched_from
        }.to_json
      })

      response = HTTParty.post("#{Toolshed::Client::GITHUB_BASE_API_URL}repos/#{Toolshed::Client.branched_from_user}/#{Toolshed::Client.branched_from_repo_name}/pulls", options).response
      response = JSON.parse(response.body)

      if (response["errors"].nil?)
        response
      else
        raise "validation errors #{response.inspect}"
      end
    end

    def list_branches(options={})
      options.merge!(@default_options)

      response = HTTParty.get("#{Toolshed::Client::GITHUB_BASE_API_URL}repos/#{Toolshed::Client.github_username}/toolshed/branches", options).response
      JSON.parse(response.body).each do |branch|
        puts branch.inspect
      end
    end

    def branch_name
      # branch information
      branch_name = `git rev-parse --abbrev-ref HEAD`.strip
    end

    def branched_from
      branched_from = `git rev-parse --abbrev-ref --symbolic-full-name @{u}`.split('/')[-1].strip
    end
  end
end
