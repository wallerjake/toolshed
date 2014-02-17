module Toolshed
  module Commands
    class CreatePullRequest
      def execute(args, options = {})
        # see what branch is checked out and where we are branched from
        puts "Current Branch: #{Toolshed::Git::Base.branch_name}"
        puts "Branched From: #{Toolshed::Git::Base.branched_from}"
        puts "Using Defaults: #{(Toolshed::Client.use_defaults.nil?) ? 'No' : 'Yes'}"

        ticket_tracking_url = ''
        ticket_tracking_title = ''
        ticket_id = ''

        if (Toolshed::Client.ticket_tracking_tool == 'pivotal_tracker')
          pivotal_tracker = Toolshed::TicketTracking::PivotalTracker.get_pivotal_tracker_by_project_id_command
          pivotal_tracker_story_information = pivotal_tracker.get_story_by_story_id

          ticket_tracking_url = pivotal_tracker_story_information.url
          ticket_tracking_title = Toolshed::TicketTracking::PivotalTracker.clean_title(pivotal_tracker_story_information.name)
          ticket_id = pivotal_tracker_story_information.id

          puts "Ticket Tracking URL: #{ticket_tracking_url}"
          puts "Ticket Tracking title: #{ticket_tracking_title}"
          puts "Ticket ID: #{ticket_id}"
        end

        if (Toolshed::Client.git_tool == 'github')
          pull_request_url = ''

          begin
            github = Toolshed::Git::Github.new({ username: Toolshed::Git::Github.username, password: Toolshed::Git::Github.password })
            github_pull_request_result = github.create_pull_request_command(ticket_tracking_title, ticket_tracking_url)
            pull_request_url = github_pull_request_result["html_url"]

            if (Toolshed::Client.ticket_tracking_tool == 'pivotal_tracker')
              if (Toolshed::Client.use_defaults)
                update_pt_info = 'y'
              else
                print "Would you like to add a note to PivotalTracker with the pull request URL(y/n)? "
                update_pt_info = $stdin.gets.chomp.strip
              end

              if (update_pt_info == 'y')
                result = pivotal_tracker.add_note(ticket_id, pull_request_url)
                result = pivotal_tracker.update_story_state(ticket_id, Toolshed::TicketTracking::PivotalTracker::STORY_STATUS_DEFAULT)
              end
            end
          rescue => e
            puts e.message
            exit
          end
        else
          puts "Git tool is undefined implementation needed"
          exit
        end
      end
    end
  end
end
