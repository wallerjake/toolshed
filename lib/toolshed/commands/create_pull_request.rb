module Toolshed
  module Commands
    class CreatePullRequest
      attr_accessor :ticket_tracking_url, :ticket_tracking_title,
                    :ticket_id, :ticket_tracker,
                    :ticket_tracker_class, :ticket_tracker_project_id,
                    :pull_request_url, :git_tool,
                    :pull_request_title, :pull_request_body

      def initialize(options={})
        self.ticket_tracker_class = nil
        self.pull_request_url = ''
      end

      def execute(args, options = {})
        output_begining_messages
        options = execute_ticket_tracking(options)
        options = execute_pull_request(options) unless options.nil?
      end

      private

        def read_user_input_add_note_to_ticket(message)
          return true if (Toolshed::Client.use_defaults)

          puts message
          value = $stdin.gets.chomp

          until %w(y n).include?(value.downcase)
            puts "Value must be Y or N"
            puts message
            value = $stdin.gets.chomp
          end

          (value == 'y') ? true : false
        end

        def read_user_input(message, options)
          return options[:default] if Toolshed::Client.use_defaults
          return options[:title] if options.has_key?(:title)
          return options[:body] if options.has_key?(:body)

          puts message
          value = $stdin.gets.chomp
          value = options[:default] if value.empty?
          value
        end

        def read_user_input_ticket_tracker_ticket_id(message, options)
          read_user_input(message, options)
        end

        def output_begining_messages
          puts "Current Branch: #{Toolshed::Git::Base.branch_name}"
          puts "Branched From: #{Toolshed::Git::Base.branched_from}"
          puts "Using Defaults: #{(Toolshed::Client.use_defaults.nil?) ? 'No' : 'Yes'}"
        end

        def use_ticket_tracker_project_id(options)
          options
          options.merge!({
            ticket_tracker_const: 'USE_PROJECT_ID',
            type: :project_id,
            default_method: 'default_pivotal_tracker_project_id',
            default_message: "Project ID (Default: #{Toolshed::Client.default_pivotal_tracker_project_id}):",
          })
          options = use_ticket_tracker_by_type(options)
        end

        def use_ticket_tracker_project_name(options)
          options.merge!({
            ticket_tracker_const: 'USE_PROJECT_NAME',
            type: :project,
            default_method: 'default_ticket_tracker_project',
            default_message: "Project Name (Default: #{Toolshed::Client.default_ticket_tracker_project}):",
          })
          options = use_ticket_tracker_by_type(options)
        end

        def use_ticket_tracker_by_type(options)
          use_field = Object.const_get("#{ticket_tracker_class}::#{options[:ticket_tracker_const]}") rescue false
          if use_field
            ticket_tracker_response = read_user_input(options[:default_message],
              options.merge!({ default: Toolshed::Client.send(options[:default_method]) })
            )
            options.merge!({ options[:type] => ticket_tracker_response })
          end
          options
        end

        def get_ticket_id(options)
          self.ticket_id = read_user_input_ticket_tracker_ticket_id(
            "Ticket ID (Default: #{Toolshed::TicketTracking::story_id_from_branch_name(Toolshed::Git::Base.branch_name)}):", {
              default: Toolshed::TicketTracking::story_id_from_branch_name(Toolshed::Git::Base.branch_name),
            }
          )
          options.merge!({
            ticket_id: self.ticket_id,
          })
          options
        end

        def output_ticket_information
          puts "Ticket Tracking URL: #{ticket_tracking_url}"
          puts "Ticket Tracking title: #{ticket_tracking_title}"
          puts "Ticket ID: #{ticket_id}"
        end

        def execute_ticket_tracking(options)
          unless Toolshed::Client.ticket_tracking_tool.nil? || Toolshed::Client.ticket_tracking_tool.empty?
            begin
              self.ticket_tracker_class =  Object.const_get("Toolshed::TicketTracking::#{Toolshed::Client.ticket_tracking_tool.camel_case}")
              options = get_ticket_project_information(options)
              initialize_ticket_tracker_properties(options)

              output_ticket_information
            rescue Exception => e
              puts e.inspect
              puts e.backtrace
              puts "Ticket tracking tool is not supported at this time"
              return
            end
            options
          end
          options
        end

        def add_note_to_ticket
          add_note_to_ticket_response = read_user_input_add_note_to_ticket(
            "Would you like to add a note with the pull request url?"
          )
          if add_note_to_ticket_response
            result = self.ticket_tracker.add_note(pull_request_url)
            default_completed_status = Object.const_get("#{ticket_tracker_class}::DEFAULT_COMPLETED_STATUS") rescue false
            default_completed_status = Toolshed::Client.ticket_status_for_complete unless default_completed_status
            ticket_tracker.update_ticket_status(default_completed_status)
          end
        end

        def pull_request_created_message
          puts "Created Pull Request: #{pull_request_url}"
        end

        def execute_pull_request(options)
          begin
            self.git_tool = Object.const_get("Toolshed::Git::#{Toolshed::Client.git_tool.camel_case}").create_instance

            options = set_pull_request_title(options)
            options = set_pull_request_body(options)
            send_pull_request
            add_note_to_ticket unless ticket_tracker_class.nil?
            pull_request_created_message
          rescue => e
            puts e.message
            exit
          end
        end

        def set_pull_request_title(options)
          self.pull_request_title = read_user_input(
            "Pull request title (Default: #{self.ticket_tracking_title}):",
            options.merge!({
              default: self.ticket_tracking_title,
            })
          )
          options
        end

        def set_pull_request_body(options)
          self.pull_request_body = read_user_input(
            "Pull request body (Default: #{self.ticket_tracking_url}):",
            options.merge!({
              default: self.ticket_tracking_url
            })
          )
          options
        end

        def send_pull_request
          puts "Pull request being created"
          git_pull_request_result = self.git_tool.create_pull_request('Sample', 'Sample Body')
          self.pull_request_url = git_pull_request_result["html_url"]
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
