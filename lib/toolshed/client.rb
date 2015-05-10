require 'singleton'
require 'toolshed/version'
require 'yaml'

module Toolshed
  class Client
    include Singleton

    attr_accessor :debug,
                  :git_quiet,
                  :use_defaults,
                  :github_username,
                  :github_password,
                  :github_token,
                  :use_defaults,
                  :pull_from_repository_user,
                  :pull_from_repository_name,
                  :pull_from_remote_name,
                  :push_to_repository_user,
                  :push_to_remote_name,
                  :use_git_submodules,
                  :git_tool,
                  :pivotal_tracker_username,
                  :pivotal_tracker_password,
                  :default_pivotal_tracker_project_id,
                  :ticket_tracker_username,
                  :ticket_tracker_password,
                  :default_ticket_tracker_project,
                  :ticket_tracking_tool,
                  :ticket_tracker_owner,
                  :ticket_status_for_complete,
                  :default_pull_request_title_format,
                  :time_tracking_tool,
                  :time_tracking_username,
                  :time_tracking_password,
                  :time_tracking_owner,
                  :time_tracking_default_project_id,
                  :load_credentials_if_necessary

    GITHUB_BASE_API_URL  = "https://api.github.com/"
    PIVOTAL_TRACKER_BASE_API_URL = "https://www.pivotaltracker.com/services/v5/"

    class << self
      def config_path
        ENV['TOOLSHED_CONFIG'] || '~/.toolshedrc'
      end

      def load_credentials(path = config_path)
        credentials = Client.read_credenials(config_path)
        instance.github_username                    ||= credentials['github_username']
        instance.github_password                    ||= credentials['github_password']
        instance.github_token                       ||= credentials['github_token']
        instance.pivotal_tracker_username           ||= credentials['pivotal_tracker_username']
        instance.pivotal_tracker_password           ||= credentials['pivotal_tracker_password']
        instance.default_pivotal_tracker_project_id ||= credentials['default_pivotal_tracker_project_id']
        instance.ticket_tracker_username            ||= credentials['ticket_tracker_username']
        instance.ticket_tracker_password            ||= credentials['ticket_tracker_password']
        instance.ticket_tracker_owner               ||= credentials['ticket_tracker_owner']
        instance.ticket_status_for_complete         ||= credentials['ticket_status_for_complete']
        instance.default_ticket_tracker_project     ||= credentials['default_ticket_tracker_project']
        instance.pull_from_remote_name              ||= credentials['pull_from_remote_name']
        instance.pull_from_repository_user          ||= credentials['pull_from_repository_user']
        instance.pull_from_repository_name          ||= credentials['pull_from_repository_name']
        instance.push_to_repository_user            ||= credentials['push_to_repository_user']
        instance.push_to_remote_name                ||= credentials['push_to_remote_name']
        instance.ticket_tracking_tool               ||= credentials['ticket_tracking_tool']
        instance.use_git_submodules                 ||= credentials['use_git_submodules']
        instance.git_tool                           ||= credentials['git_tool']
        instance.time_tracking_username             ||= credentials['time_tracking_username']
        instance.time_tracking_password             ||= credentials['time_tracking_password']
        instance.time_tracking_owner                ||= credentials['time_tracking_owner']
        instance.time_tracking_default_project_id   ||= credentials['time_tracking_default_project_id']
        instance.time_tracking_tool                 ||= credentials['time_tracking_tool']
        instance.git_quiet                          ||= (credentials['git_quiet']) ? '&> /dev/null' : ''
        instance.use_defaults                       ||= credentials['use_defaults']
        instance.default_pull_request_title_format  ||= credentials['default_pull_request_title_format']
      end

      def read_credenials(path = Client.config_path)
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

          puts "Credentials loaded from #{File.absolute_path(loaded_from_path)}"
          credentials = YAML.load_file(File.expand_path(loaded_from_path))
        rescue => error
          puts "Error loading your credentials: #{error.message}"
          exit 1
        end
      end
    end
  end
end
