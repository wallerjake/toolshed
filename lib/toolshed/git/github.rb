module Toolshed
  module Git
    class Github < Base
      extend Toolshed::Git
      include HTTParty

      def initialize(options={})
        super(options)

        username = Toolshed::Client::github_username
        password = Toolshed::Client::github_password

        unless (options[:username].nil?)
          username = options[:username]
        end

        unless (options[:password].nil?)
           password = options[:password]
        end

        @auth = { username: username, password: password }
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
             head: "#{Toolshed::Client.github_username}:#{Toolshed::Git.branch_name}",
             base: Toolshed::Git.branched_from
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

      def self.username
        username = Toolshed::Client::github_username
        if (username.nil?)
          # prompt to ask for username
          puts "Github username? "
          username = $stdin.gets.chomp.strip
        end

        return username
      end

      def self.password
        password = Toolshed::Client::github_password
        if (password.nil?)
          # prompt to ask for password
          system "stty -echo"
          puts "Github password? "
          password = $stdin.gets.chomp.strip
          system "stty echo"
        end

        return password
      end

      #
      # Create a pull request with the given title and body
      #
      def create_pull_request_command(default_title, default_body)
        print "Pull Request Title (Default: #{default_title})? "
        title = $stdin.gets.chomp.strip
        if (title == '')
          title = default_title
        end

        print "Pull Request Body (Default: #{default_body})? "
        body = $stdin.gets.chomp.strip
        if (body == '')
          body = default_body
        end

        puts "Running Github Pull Request"
        github_pull_request_result = self.create_pull_request(title, body)
        puts "Github Pull Request URL: #{github_pull_request_result["html_url"]}"

        return github_pull_request_result
      end
    end
  end
end
