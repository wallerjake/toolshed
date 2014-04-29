require 'toolshed/version'
require 'yaml'

module Toolshed
  class Client
    GITHUB_BASE_API_URL  = "https://api.github.com/"
    PIVOTAL_TRACKER_BASE_API_URL = "https://www.pivotaltracker.com/services/v5/"

    # debugging options
    def self.debug?
      @debug
    end

    def self.debug=(debug)
      @debug = debug
    end

    def self.git_quiet
      @git_quiet
    end

    def self.git_quiet=(git_quiet)
      @git_quiet = git_quiet
    end

    def self.use_defaults
      @use_defaults
    end

    def self.use_defaults=(use_defaults)
      @use_defaults = use_defaults
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

    def self.github_token
      @github_token
    end

    def self.github_token=(token)
      @github_token = token
    end

    def self.pull_from_remote_name
      @pull_from_remote_name
    end

    def self.pull_from_remote_name=(pull_from_remote_name)
      @pull_from_remote_name = pull_from_remote_name
    end

    def self.pull_from_repository_user
      @pull_from_repository_user
    end

    def self.pull_from_repository_user=(pull_from_repository_user)
      @pull_from_repository_user = pull_from_repository_user
    end

    def self.pull_from_repository_name
      @pull_from_repository_name
    end

    def self.pull_from_repository_name=(pull_from_repository_name)
      @pull_from_repository_name = pull_from_repository_name
    end

    def self.push_to_repository_user
      @push_to_repository_user
    end

    def self.push_to_repository_user=(push_to_repository_user)
      @push_to_repository_user = push_to_repository_user
    end

    def self.push_to_remote_name
      @push_to_remote_name
    end

    def self.push_to_remote_name=(push_to_remote_name)
      @push_to_remote_name = push_to_remote_name
    end

    def self.use_git_submodules
      @use_git_submodules
    end

    def self.use_git_submodules=(use_git_submodules)
      @use_git_submodules = use_git_submodules
    end

    def self.git_tool
      (@git_tool.nil?) ? Toolshed::Git::DEFAULT_GIT_TOOL : @git_tool
    end

    def self.git_tool=(git_tool)
      @git_tool = git_tool
    end


    # ticket tracking information

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

    def self.ticket_tracker_username
      @ticket_tracker_username
    end

    def self.ticket_tracker_username=(username)
      @ticket_tracker_username = username
    end

    def self.ticket_tracker_password
      @ticket_tracker_password
    end

    def self.ticket_tracker_password=(password)
      @ticket_tracker_password = password
    end

    def self.default_ticket_tracker_project
      @default_ticket_tracker_project
    end

    def self.default_ticket_tracker_project=(default_ticket_tracker_project)
      @default_ticket_tracker_project = default_ticket_tracker_project
    end

    def self.ticket_tracking_tool
      @ticket_tracking_tool
    end

    def self.ticket_tracking_tool=(ticket_tracking_tool)
      @ticket_tracking_tool = ticket_tracking_tool
    end

    def self.ticket_tracker_owner
      @ticket_tracker_owner
    end

    def self.ticket_tracker_owner=(owner)
      @ticket_tracker_owner = owner
    end

    def self.ticket_status_for_complete
      @ticket_status_for_complete
    end

    def self.ticket_status_for_complete=(status)
      @ticket_status_for_complete = status
    end

    # time tracking configuration

    def self.time_tracking_tool
      @time_tracking_tool
    end

    def self.time_tracking_tool=(time_tracking_tool)
      @time_tracking_tool = time_tracking_tool
    end

    def self.time_tracking_username
      @time_tracking_username
    end

    def self.time_tracking_username=(time_tracking_username)
      @time_tracking_username = time_tracking_username
    end

    def self.time_tracking_password
      @time_tracking_password
    end

    def self.time_tracking_password=(time_tracking_password)
      @time_tracking_password = time_tracking_password
    end

    def self.time_tracking_owner
      @time_tracking_owner
    end

    def self.time_tracking_owner=(time_tracking_owner)
      @time_tracking_owner = time_tracking_owner
    end

    def self.time_tracking_default_project_id
      @time_tracking_default_project_id
    end

    def self.time_tracking_default_project_id=(time_tracking_default_project_id)
      @time_tracking_default_project_id = time_tracking_default_project_id
    end



    def self.load_credentials_if_necessary
      load_credentials unless credentials_loaded?
    end

    def self.config_path
      ENV['TOOLSHED_CONFIG'] || '~/.toolshed'
    end

    def self.load_credentials(path = config_path)
      begin
        dir = Dir.pwd
        while File.expand_path(dir) != '/' do
          if (File.exists? "#{dir}/.toolshedrc")
            loaded_from_path = "#{dir}/.toolshedrc"
            break
          elsif (File.exists? "#{dir}/.toolshed")
            loaded_from_path = "#{dir}/.toolshed"
            warn "[DEPRECATION] `.toolshed` file is being deprecated.  Please use a `.toolshedrc` file instead."
            break
          end

          dir = File.join dir, '..'
        end

        credentials = YAML.load_file(File.expand_path(loaded_from_path))
        self.github_username                    ||= credentials['github_username']
        self.github_password                    ||= credentials['github_password']
        self.github_token                       ||= credentials['github_token']
        self.pivotal_tracker_username           ||= credentials['pivotal_tracker_username']
        self.pivotal_tracker_password           ||= credentials['pivotal_tracker_password']
        self.default_pivotal_tracker_project_id ||= credentials['default_pivotal_tracker_project_id']
        self.ticket_tracker_username            ||= credentials['ticket_tracker_username']
        self.ticket_tracker_password            ||= credentials['ticket_tracker_password']
        self.ticket_tracker_owner               ||= credentials['ticket_tracker_owner']
        self.ticket_status_for_complete         ||= credentials['ticket_status_for_complete']
        self.default_ticket_tracker_project     ||= credentials['default_ticket_tracker_project']
        self.pull_from_remote_name              ||= credentials['pull_from_remote_name']
        self.pull_from_repository_user          ||= credentials['pull_from_repository_user']
        self.pull_from_repository_name          ||= credentials['pull_from_repository_name']
        self.push_to_repository_user            ||= credentials['push_to_repository_user']
        self.push_to_remote_name                ||= credentials['push_to_remote_name']
        self.ticket_tracking_tool               ||= credentials['ticket_tracking_tool']
        self.use_git_submodules                 ||= credentials['use_git_submodules']
        self.git_tool                           ||= credentials['git_tool']
        self.time_tracking_username             ||= credentials['time_tracking_username']
        self.time_tracking_password             ||= credentials['time_tracking_password']
        self.time_tracking_owner                ||= credentials['time_tracking_owner']
        self.time_tracking_default_project_id   ||= credentials['time_tracking_default_project_id']
        self.time_tracking_tool                 ||= credentials['time_tracking_tool']
        self.git_quiet                          ||= (credentials['git_quiet']) ? '&> /dev/null' : ''
        self.use_defaults                       ||= credentials['use_defaults']
        @credentials_loaded = true
        puts "Credentials loaded from #{File.absolute_path(loaded_from_path)}"
      rescue => error
        puts "Error loading your credentials: #{error.message}"
        exit 1
      end
    end

    def self.credentials_loaded?
      (@credentials_loaded ||= false)
    end
  end
end
