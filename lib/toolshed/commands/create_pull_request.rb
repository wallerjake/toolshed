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

            if Object.const_get("#{ticket_tracker_class}::USE_PROJECT_ID")
              ticket_tracker_project_id = read_user_input_ticket_tracker_project_id("Project ID (Default: #{Toolshed::Client.default_pivotal_tracker_project_id}):", { default: Toolshed::Client.default_pivotal_tracker_project_id })
              options.merge!({ project_id: ticket_tracker_project_id })
            end

            ticket_tracker = ticket_tracker_class.create_instance(options)

            # @TODO - refactor this code into the git module seems more appropriate since it's performing git functions
            ticket_id = read_user_input_ticket_tracker_ticket_id("Ticket ID (Default: #{Toolshed::TicketTracking::PivotalTracker::story_id_from_branch_name(Toolshed::Git::Base.branch_name)}):", { default: Toolshed::TicketTracking::PivotalTracker::story_id_from_branch_name(Toolshed::Git::Base.branch_name) })
            ticket_information = ticket_tracker.story_information(ticket_id)

            ticket_tracking_url = ticket_information.url
            ticket_tracking_title = ticket_tracker_class.clean(ticket_information.name)
            ticket_id = ticket_information.id

            puts "Ticket Tracking URL: #{ticket_tracking_url}"
            puts "Ticket Tracking title: #{ticket_tracking_title}"
            puts "Ticket ID: #{ticket_id}"
          rescue Exception => e
            puts "Ticket tracking tool is not supported at this time"
            return
          end
        end

        pull_request_url = ''
        begin
          git_tool_class = Object.const_get("Toolshed::Git::#{Toolshed::Client.git_tool.camel_case}")
          git_tool = git_tool_class.create_instance

          # create the pull request prompt when needed
          title = read_user_input_pull_request_title("Pull request title (Default: #{ticket_tracking_title}):", options.merge!({ default: ticket_tracking_title }))
          body = read_user_input_pull_request_body("Pull request body (Default: #{ticket_tracking_url}):", options.merge!({ default: ticket_tracking_url }))

          puts "Pull request being created"
          git_pull_request_result = git_tool.create_pull_request(title, body)
          pull_request_url = git_pull_request_result["html_url"]

          unless (Toolshed::Client.ticket_tracking_tool.nil? || Toolshed::Client.ticket_tracking_tool.empty?)
            add_note_to_ticket = read_user_input_add_note_to_ticket("Would you like to add a note with the pull request url?")
            if (add_note_to_ticket)
              result = ticket_tracker.add_note(ticket_id, pull_request_url)
              result = ticket_tracker.update_ticket_status(ticket_id, Object.const_get("#{ticket_tracker_class}::DEFAULT_COMPLETED_STATUS"))
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

      def read_user_input_ticket_tracker_project_id(message, options)
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
