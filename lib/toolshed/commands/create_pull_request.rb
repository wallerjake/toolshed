module Toolshed
  module Commands
    class CreatePullRequest
      def execute(args, options = {})
        # see what branch is checked out and where we are branched from
        puts "Current Branch: #{Toolshed::Git::Base.branch_name}"
        puts "Branched From: #{Toolshed::Git::Base.branched_from}"
        puts "Using Defaults: #{(Toolshed::Client.use_defaults.nil?) ? 'No' : 'Yes'}"

        unless (Toolshed::Client.ticket_tracking_tool.nil? || Toolshed::Client.ticket_tracking_tool.empty?)
          ticket_tracking_url = ''
          ticket_tracking_title = ''
          ticket_id = ''

          begin
            ticket_tracker_class =  Object.const_get("Toolshed::TicketTracking::#{Toolshed::Client.ticket_tracking_tool.camel_case}")

            use_project_id = Object.const_get("#{ticket_tracker_class}::USE_PROJECT_ID") rescue false
            if use_project_id
              ticket_tracker_project_id = read_user_input_project(
                "Project ID (Default: #{Toolshed::Client.default_pivotal_tracker_project_id}):",
                options.merge!({
                  default: Toolshed::Client.default_pivotal_tracker_project_id,
                })
              )
              options.merge!({
                project_id: ticket_tracker_project_id,
              })
            end

            use_project_name = Object.const_get("#{ticket_tracker_class}::USE_PROJECT_NAME") rescue false
            if use_project_name
              ticket_tracker_project_name = read_user_input_project(
                "Project Name (Default: #{Toolshed::Client.default_ticket_tracker_project}):", options.merge!({
                  default: Toolshed::Client.default_ticket_tracker_project,
                })
              )
              options.merge!({
                project: ticket_tracker_project_name,
              })
            end

            # @TODO - refactor this code into the git module seems more appropriate since it's performing git functions
            ticket_id = read_user_input_ticket_tracker_ticket_id(
              "Ticket ID (Default: #{Toolshed::TicketTracking::story_id_from_branch_name(Toolshed::Git::Base.branch_name)}):", {
                default: Toolshed::TicketTracking::story_id_from_branch_name(Toolshed::Git::Base.branch_name),
              }
            )
            options.merge!({
              ticket_id: ticket_id,
            })

            ticket_tracker = ticket_tracker_class.create_instance(options)

            ticket_tracking_url = ticket_tracker.url
            ticket_tracking_title = ticket_tracker.default_title
            ticket_id = ticket_id

            puts "Ticket Tracking URL: #{ticket_tracking_url}"
            puts "Ticket Tracking title: #{ticket_tracking_title}"
            puts "Ticket ID: #{ticket_id}"
          rescue Exception => e
            puts e.inspect
            puts "Ticket tracking tool is not supported at this time"
            return
          end
        end

        pull_request_url = ''
        begin
          git_tool_class = Object.const_get("Toolshed::Git::#{Toolshed::Client.git_tool.camel_case}")
          git_tool = git_tool_class.create_instance

          # create the pull request prompt when needed
          title = read_user_input_pull_request_title(
            "Pull request title (Default: #{ticket_tracking_title}):",
            options.merge!({
              default: ticket_tracking_title,
            })
          )
          body = read_user_input_pull_request_body(
            "Pull request body (Default: #{ticket_tracking_url}):",
            options.merge!({
              default: ticket_tracking_url
            })
          )

          puts "Pull request being created"
          git_pull_request_result = git_tool.create_pull_request(title, body)
          pull_request_url = git_pull_request_result["html_url"]

          unless (Toolshed::Client.ticket_tracking_tool.nil? || Toolshed::Client.ticket_tracking_tool.empty?)
            add_note_to_ticket = read_user_input_add_note_to_ticket("Would you like to add a note with the pull request url?")
            if (add_note_to_ticket)
              result = ticket_tracker.add_note(pull_request_url)

              default_completed_status = Object.const_get("#{ticket_tracker_class}::DEFAULT_COMPLETED_STATUS") rescue false
              unless (default_completed_status)
                default_completed_status = Toolshed::Client.ticket_status_for_complete
              end

              result = ticket_tracker.update_ticket_status(default_completed_status)
            end
          end

          puts "Created Pull Request: #{pull_request_url}"
        rescue => e
          puts e.message
          exit
        end
      end

      def read_user_input_add_note_to_ticket(message)
        return true if (Toolshed::Client.use_defaults)

        puts message
        value = $stdin.gets.chomp

        until (%w(y n).include?(value.downcase))
          puts "Value must be Y or N"
          puts message
          value = $stdin.gets.chomp
        end

        (value == 'y') ? true : false
      end

      def read_user_input_pull_request_title(message, options)
        return options[:title] if (options.has_key?(:title))
        return options[:default] if (Toolshed::Client.use_defaults)

        puts message
        value = $stdin.gets.chomp
        if (value.empty?)
          value = options[:default]
        end

        value
      end

      def read_user_input_pull_request_body(message, options)
        return options[:body] if (options.has_key?(:body))
        return options[:default] if (Toolshed::Client.use_defaults)

        puts message
        value = $stdin.gets.chomp

        if (value.empty?)
          value = options[:default]
        end

        value
      end

      def read_user_input_project(message, options)
        return options[:default] if (Toolshed::Client.use_defaults)

        puts message
        value = $stdin.gets.chomp

        if (value.empty?)
          value = options[:default]
        end

        value
      end

      def read_user_input_ticket_tracker_ticket_id(message, options)
        return options[:default] if (Toolshed::Client.use_defaults)

        puts message
        value = $stdin.gets.chomp

        if (value.empty?)
          value = options[:default]
        end

        value
      end
    end
  end
end
