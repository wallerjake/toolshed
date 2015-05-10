module Toolshed
  module Git
    class Github < Base
      extend Toolshed::Git
      include HTTParty

      attr_accessor :default_options

      def initialize(options={})
        super(options)

        username  = Toolshed::Client.instance.github_username
        password  = Toolshed::Client.instance.github_password
        token     = Toolshed::Client.instance.github_token

        unless (options[:username].nil?)
          username = options[:username]
        end

        unless (options[:password].nil?)
           password = options[:password]
        end

        unless (token.nil?)
          username = token
          password = nil
        end

        unless (options[:token].nil?)
          username = options[:token]
          password = nil
        end

        @auth = { username: username, password: password }
        self.default_options = {
          :headers => {
              "User-Agent" => "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_8_2) AppleWebKit/537.17 (KHTML, like Gecko) Chrome/24.0.1309.0 Safari/537.17",
          },
          basic_auth: @auth,
        }
      end

      def create_pull_request(title, body, options={})
        options.merge!(self.default_options)
        options.merge!({
          body: {
            title: title,
             body: body,
             head: "#{Toolshed::Client.instance.github_username}:#{Toolshed::Git::Base.branch_name}",
             base: Toolshed::Git::Base.branched_from
          }.to_json
        })

        response = HTTParty.post("#{Toolshed::Client::GITHUB_BASE_API_URL}repos/#{Toolshed::Client.instance.pull_from_repository_user}/#{Toolshed::Client.instance.pull_from_repository_name}/pulls", options).response
        response = JSON.parse(response.body)
        if (response["errors"].nil?)
          response
        else
          raise "validation errors #{response.inspect}"
        end
      end

      def list_branches(options={})
        options.merge!(self.default_options)

        response = HTTParty.get("#{Toolshed::Client::GITHUB_BASE_API_URL}repos/#{Toolshed::Client.instance.github_username}/#{Toolshed::Client.instance.pull_from_repository_name}/branches", options).response
        response = JSON.parse(response.body)
      end

      def self.username
        username = Toolshed::Client.instance.github_username
        if (username.nil?)
          # prompt to ask for username
          puts "Github username? "
          username = $stdin.gets.chomp.strip
        end

        return username
      end

      def self.password
        password = Toolshed::Client.instance.github_password
        if (password.nil?)
          # prompt to ask for password
          system "stty -echo"
          puts "Github password? "
          password = $stdin.gets.chomp.strip
          system "stty echo"
        end

        return password
      end

      def self.create_instance
        Toolshed::Git::Github.new({ username: Toolshed::Git::Github.username, password: Toolshed::Git::Github.password })
      end
    end
  end
end
