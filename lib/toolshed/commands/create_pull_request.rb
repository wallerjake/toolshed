module Toolshed
  module Commands
    class CreatePullRequest
      def execute(args, options = {})
        # see what branch is checked out and where we are branched from
        puts "Current Branch: #{Toolshed::Git::Base.branch_name}"
        puts "Branched From: #{Toolshed::Git::Base.branched_from}"
        puts "Using Defaults: #{(Toolshed::Client.use_defaults.nil?) ? 'No' : 'Yes'}"

        unless (Toolshed::Client.ticket_tracking_tool.empty?)
          ticket_tracking_url = ''
          ticket_tracking_title = ''
          ticket_id = ''

          begin
            ticket_tracker_class = "Toolshed::TicketTracking::#{Toolshed::Client.ticket_tracking_tool.camel_case}".constantize
            ticket_tracker = ticket_tracker_class.create_instance
            ticket_information = pivotal_tracker.get_ticket_information

            ticket_tracking_url = ticket_information.url
            ticket_tracking_title = ticket_tracker_class.clean(ticket_information.name)
            ticket_id = pivotal_tracker_story_information.id

            puts "Ticket Tracking URL: #{ticket_tracking_url}"
            puts "Ticket Tracking title: #{ticket_tracking_title}"
            puts "Ticket ID: #{ticket_id}"
          rescue
            puts "Ticket tracking tool is not supported at this time"
            exit
          end
        end

        pull_request_url = ''
        begin
          git_tool_class = "Toolshed::Git::#{Toolshed::Client.git_tool}".constantize
          git_tool = git_tool_class.create_instance

          # create the pull request prompt when needed
          title = read_user_input_pull_request_title("Pull request title (Default: #{ticket_tracking_title}):", ticket_tracking_title)
          body = read_user_input_pull_request_body("Pull request body (Default: #{ticket_tracking_url}):", ticket_tracking_url)

          puts "Pull request being created"
          git_pull_request_result = git_tool.create_pull_request(title, body)
          pull_request_url = git_pull_request_result["html_url"]

          add_note_to_ticket = read_user_input_add_note_to_ticket("Would you like to add a note with the pull request url?")
          if (add_note_to_ticket)
            result = ticket_tracker.add_note(ticket_id, pull_request_url)
            result = ticket_tracker.update_ticket_status(ticket_id, "#{ticket_tracker_class}::DEFAULT_COMPLETED_STATUS".constantize)
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
    end

    def read_user_input_pull_request_title(message, default)
      return default if (Toolshed::Client.use_defaults)

      puts message
      value = $stdin.gets.chomp
      if (value.empty?)
        value = default
      end

      value
    end

    def read_user_input_pull_request_body(message, default)
      return default if (Toolshed::Client.use_defaults)

      puts message
      value = $stdin.gets.chomp

      if (value.empty?)
        value = default
      end

      value
    end
  end
end
