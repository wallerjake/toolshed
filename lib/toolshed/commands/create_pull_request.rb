require 'toolshed/commands/base'
require 'toolshed/git'
require 'toolshed/git/github'

module Toolshed
  module Commands
    # Allow a user to create pull request based on information in .toolshedrc and prompts
    class CreatePullRequest < Toolshed::Commands::Base # rubocop:disable ClassLength, LineLength
      attr_accessor :ticket_tracking_url, :ticket_tracking_title,
                    :ticket_id, :ticket_tracker,
                    :ticket_tracker_class, :ticket_tracker_project_id,
                    :pull_request_url, :git_tool,
                    :pull_request_title, :pull_request_body

      def initialize(options = {})
        super(options)
        self.ticket_tracker_class = nil
        self.pull_request_url = ''
      end

      def self.cli_options # rubocop:disable Metrics/MethodLength
        {
          banner: 'Usage: push_branch [options]',
          options: {
            tool: {
              short_on: '-a'
            },
            ticket_system: {
              short_on: '-s'
            },
            use_defaults: {
              short_on: '-d'
            },
            title: {
              short_on: '-t'
            },
            body: {
              short_on: '-b'
            }
          }
        }
      end

      def execute(_args, options = {})
        output_begining_messages
        options = execute_ticket_tracking(options)
        execute_pull_request(options) unless options.nil?
      end

      def git
        @git ||= begin
          Toolshed::Git.new
        end
      end

      private

        def read_user_input_add_note_to_ticket(message)
          return true if Toolshed::Client.instance.use_defaults

          puts message
          value = $stdin.gets.chomp

          until %w(y n).include?(value.downcase)
            puts 'Value must be Y or N'
            puts message
            value = $stdin.gets.chomp
          end

          (value == 'y') ? true : false
        end

        def read_user_input_ticket_tracker_ticket_id(message, options)
          read_user_input(message, options)
        end

        def output_begining_messages
          logger.info "Current Branch: #{git.branch_name}"
          logger.info "Branched From: #{Toolshed::Git.branched_from}"
          logger.info "Using Defaults: #{(Toolshed::Client.instance.use_defaults.nil?) ? 'No' : 'Yes'}" # rubocop:disable Metrics/LineLength
        end

        def get_ticket_id(options)
          self.ticket_id = read_user_input_ticket_tracker_ticket_id(
            "Ticket ID (Default: #{Toolshed::TicketTracking.story_id_from_branch_name(git.branch_name)}):", # rubocop:disable Metrics/LineLength
            default: Toolshed::TicketTracking.story_id_from_branch_name(git.branch_name)
          )
          options.merge!(ticket_id: ticket_id)
          options
        end

        def output_ticket_information
          logger.info "Ticket Tracking URL: #{ticket_tracking_url}"
          logger.info "Ticket Tracking title: #{ticket_tracking_title}"
          logger.info "Ticket ID: #{ticket_id}"
        end

        def execute_ticket_tracking(options) # rubocop:disable Metrics/AbcSize
          return options if Toolshed::Client.instance.ticket_tracking_tool.nil? || Toolshed::Client.instance.ticket_tracking_tool.empty? # rubocop:disable Metrics/LineLength

          begin
            self.ticket_tracker_class =  Object.const_get("Toolshed::TicketTracking::#{Toolshed::Client.instance.ticket_tracking_tool.camel_case}") # rubocop:disable Metrics/LineLength
            options = get_ticket_project_information(options)
            initialize_ticket_tracker_properties(options)

            output_ticket_information
          rescue StandardError => e
            logger.fatal e.inspect
            logger.fatal e.backtrace
            logger.fatal 'Ticket tracking tool is not supported at this time'
            return
          end

          options
        end

        def add_note_to_ticket
          add_note_to_ticket_response = read_user_input_add_note_to_ticket('Would you like to add a note with the pull request url?') # rubocop:disable Metrics/LineLength
          return unless add_note_to_ticket_response

          ticket_tracker.add_note(pull_request_url)
          completed_status = Toolshed::Client.instance.ticket_status_for_complete unless default_completed_status # rubocop:disable Metrics/LineLength
          ticket_tracker.update_ticket_status(completed_status)
        end

        def default_completed_status
          default_completed_status = nil
          begin
            default_completed_status = Object.const_get("#{ticket_tracker_class}::DEFAULT_COMPLETED_STATUS") # rubocop:disable Metrics/LineLength
          rescue
            false
          end
          default_completed_status
        end

        def pull_request_created_message
          logger.info "Created Pull Request: #{pull_request_url}"
        end

        def execute_pull_request(options) # rubocop:disable Metrics/AbcSize
          self.git_tool = Object.const_get("Toolshed::Git::#{Toolshed::Client.instance.git_tool.camel_case}").create_instance # rubocop:disable Metrics/LineLength

          options = get_pull_request_title(options)
          get_pull_request_body(options)
          send_pull_request
          add_note_to_ticket unless ticket_tracker_class.nil?
          pull_request_created_message
        rescue => e
          logger.fatal e.message
          Toolshed.die
        end

        def get_pull_request_title(options)
          self.pull_request_title = read_user_input_title(
            "Pull request title (Default: #{ticket_tracking_title}):",
            options.merge!(default: ticket_tracking_title)
          )
          options
        end

        def get_pull_request_body(options)
          self.pull_request_body = read_user_input_body(
            "Pull request body (Default: #{ticket_tracking_url}):",
            options.merge!(default: ticket_tracking_url)
          )
          options
        end

        def send_pull_request
          Toolshed.logger.info 'Your ull request is being created.'
          git_pull_request_result = git_tool.create_pull_request(pull_request_title, pull_request_body) # rubocop:disable Metrics/LineLength
          self.pull_request_url = git_pull_request_result['html_url']
        end

        def get_ticket_project_information(options)
          options = use_ticket_tracker_project_id(options)
          options = use_ticket_tracker_project_name(options)
          options = get_ticket_id(options)
          options
        end

        def initialize_ticket_tracker_properties(options)
          self.ticket_tracker = ticket_tracker_class.create_instance(options)
          self.ticket_tracking_url = ticket_tracker.url
          self.ticket_tracking_title = ticket_tracker.default_title
        end
    end
  end
end
