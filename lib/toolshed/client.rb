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

    def self.git_force
      @git_force
    end

    def self.git_force=(git_force)
      @git_force = git_force
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


    # ticket tracking configuration

    def self.ticket_tracking_tool
      @ticket_tracking_tool
    end

    def self.ticket_tracking_tool=(ticket_tracking_tool)
      @ticket_tracking_tool = ticket_tracking_tool
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
        self.pivotal_tracker_username           ||= credentials['pivotal_tracker_username']
        self.pivotal_tracker_password           ||= credentials['pivotal_tracker_password']
        self.default_pivotal_tracker_project_id ||= credentials['default_pivotal_tracker_project_id']
        self.branched_from_remote_name          ||= credentials['branched_from_remote_name']
        self.branched_from_user                 ||= credentials['branched_from_user']
        self.branched_from_repo_name            ||= credentials['branched_from_repo_name']
        self.push_from_user                     ||= credentials['push_from_user']
        self.push_to_myself                     ||= credentials['push_to_myself']
        self.ticket_tracking_tool               ||= credentials['ticket_tracking_tool']
        self.use_git_submodules                 ||= credentials['use_git_submodules']
        self.git_tool                           ||= credentials['git_tool']
        self.time_tracking_username             ||= credentials['time_tracking_username']
        self.time_tracking_password             ||= credentials['time_tracking_password']
        self.time_tracking_owner                ||= credentials['time_tracking_owner']
        self.time_tracking_default_project_id   ||= credentials['time_tracking_default_project_id']
        self.time_tracking_tool                 ||= credentials['time_tracking_tool']
        self.git_quiet                          ||= (credentials['git_quiet']) ? '--quiet' : ''
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
