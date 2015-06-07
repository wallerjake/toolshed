require 'toolshed/git'

module Toolshed
  class Git
    # Class created to handle specific git tasks related to github
    class Github < Toolshed::Git
      include HTTParty

      attr_accessor :default_options

      def initialize(options = {}) # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
        super(options)

        username  = Toolshed::Client.instance.github_username
        password  = Toolshed::Client.instance.github_password
        token     = Toolshed::Client.instance.github_token

        username = options[:username] unless options[:username].nil?
        password = options[:password] unless options[:password].nil?
        unless token.nil?
          username = token
          password = nil
        end

        unless options[:token].nil?
          username = options[:token]
          password = nil
        end

        @auth = { username: username, password: password }
        self.default_options = {
          headers: {
            'User-Agent' => 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_8_2) AppleWebKit/537.17 (KHTML, like Gecko) Chrome/24.0.1309.0 Safari/537.17' # rubocop:disable Metrics/LineLength
          },
          basic_auth: @auth
        }
      end

      def create_pull_request(title, body, options = {}) # rubocop:disable Metrics/AbcSize, Metrics/MethodLength, Metrics/LineLength
        options.merge!(default_options)
        options.merge!(
          body:
          {
            title: title,
            body: body,
            head: "#{Toolshed::Client.instance.github_username}:#{Toolshed::Git.branch_name}", # rubocop:disable Metrics/LineLength
            base: Toolshed::Git.branched_from
          }.to_json
        )
        display_options = Marshal.load(Marshal.dump(options))
        display_options[:password] = '********'
        Toolshed.logger.info "Creating pull request with the following options: #{display_options.inspect}" # rubocop:disable Metrics/LineLength
        response = HTTParty.post("#{Toolshed::Client::GITHUB_BASE_API_URL}repos/#{Toolshed::Client.instance.pull_from_repository_user}/#{Toolshed::Client.instance.pull_from_repository_name}/pulls", options).response # rubocop:disable Metrics/LineLength
        response = JSON.parse(response.body)
        if response['errors'].nil?
          response
        else
          fail "Validation errors #{response.inspect}"
        end
      end

      def self.username
        username = Toolshed::Client.instance.github_username
        return username unless username.nil?

        puts 'Github username? '
        $stdin.gets.chomp.strip
      end

      def self.password
        password = Toolshed::Client.instance.github_password
        return password unless password.nil?

        system 'stty -echo'
        puts 'Github password? '
        password = $stdin.gets.chomp.strip
        system 'stty echo'
        password
      end

      def self.create_instance
        Toolshed::Git::Github.new(username: Toolshed::Git::Github.username, password: Toolshed::Git::Github.password) # rubocop:disable Metrics/LineLength
      end
    end
  end
end
