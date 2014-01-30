require 'toolshed/version'
require 'yaml'

module Toolshed
  class Client
    GITHUB_BASE_API_URL  = "https://api.github.com/"

    def self.debug?
      @debug
    end

    def self.debug=(debug)
      @debug = debug
    end



    # github config settings
    def self.github_username
      @github_username
    end

    def self.github_username=(username)
      @github_username = username
    end

    def self.github_password
      @github_password
    end

    def self.github_password=(password)
      @github_password = password
    end

    def self.branched_from_remote_name
      @branched_from_remote_name
    end

    def self.branched_from_remote_name=(branched_from_remote_name)
      @branched_from_remote_name = branched_from_remote_name 
    end

    def self.branched_from_user
      @branched_from_user
    end

    def self.branched_from_user=(branched_from_user)
      @branched_from_user = branched_from_user 
    end

    def self.branched_from_repo_name
      @branched_from_repo_name
    end

    def self.branched_from_repo_name=(branched_from_repo_name)
      @branched_from_repo_name = branched_from_repo_name 
    end

    def self.push_from_user
      @push_from_user
    end

    def self.push_from_user=(push_from_user)
      @push_from_user = push_from_user 
    end

    def self.push_to_myself
      @push_to_myself
    end

    def self.push_to_myself=(push_to_myself)
      @push_to_myself = push_to_myself 
    end



    # pivotal tracker config
    def self.pivotal_tracker_username
      @pivotal_tracker_username
    end

    def self.pivotal_tracker_username=(username)
      @pivotal_tracker_username = username
    end

    def self.pivotal_tracker_password
      @pivotal_tracker_password
    end

    def self.pivotal_tracker_password=(password)
      @pivotal_tracker_password = password
    end

    def self.default_pivotal_tracker_project_id
      @default_pivotal_tracker_project_id
    end

    def self.default_pivotal_tracker_project_id=(default_pivotal_tracker_project_id)
      @default_pivotal_tracker_project_id = default_pivotal_tracker_project_id
    end



    def self.http_proxy
      @http_proxy
    end

    def self.http_proxy=(http_proxy)
      @http_proxy = http_proxy
    end

    def self.load_credentials_if_necessary
      load_credentials unless credentials_loaded?
    end

    def self.config_path
      ENV['TOOLSHED_CONFIG'] || '~/.toolshed'
    end

    def self.load_credentials(path = config_path)
      begin
        if (File.exists?('.toolshed'))
          credentials = YAML.load_file(File.expand_path('.toolshed'))
        else
          credentials = YAML.load_file(File.expand_path(path))
        end
        self.github_username                    ||= credentials['github_username']
        self.github_password                    ||= credentials['github_password']
        self.pivotal_tracker_username           ||= credentials['pivotal_tracker_username']
        self.pivotal_tracker_password           ||= credentials['pivotal_tracker_password']
        self.default_pivotal_tracker_project_id ||= credentials['default_pivotal_tracker_project_id']
        self.branched_from_remote_name          ||= credentials['branched_from_remote_name']
        self.branched_from_user                 ||= credentials['branched_from_user']
        self.branched_from_repo_name            ||= credentials['branched_from_repo_name']
        self.push_from_user                     ||= credentials['push_from_user']
        self.push_to_myself                     ||= credentials['push_to_myself']
        @credentials_loaded = true
        puts "Credentials loaded from #{path}"
      rescue => error
        puts "Error loading your credentials: #{error.message}"
        exit 1
      end
    end

    def self.credentials_loaded?
      (@credentials_loaded ||= false) or (github_username and github_password and pivotal_tracker_username and pivotal_tracker_password)
    end

    def self.base_options
      options = {
        :format => :json,
        :headers => { 'Accept' => 'application/json', 'User-Agent' => "toolshed-ruby/#{Toolshed::VERSION}" },
      }

      if http_proxy
        options.merge!(
          :http_proxyaddr => self.http_proxy[:addr],
          :http_proxyport => self.http_proxy[:port]
        )
      end

      if password
        options[:basic_auth] = { :username => username, :password => password }
      else
        raise Error, 'A password is required for all API requests.'
      end

      options
    end

    def self.get(path, options = {})
      request :get, path, options
    end

    def self.post(path, options = {})
      request :post, path, options
    end

    def self.put(path, options = {})
      request :put, path, options
    end

    def self.delete(path, options = {})
      request :delete, path, options
    end

    def self.request(method, path, options)
      response = HTTParty.send(method, "#{base_uri}#{path}", base_options.merge(options))

      if response.code == 401
        raise AuthenticationFailed
      end

      response
    end
  end
end
