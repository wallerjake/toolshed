module Toolshed
  module Commands
    class CreatePullRequest
      def execute(args, options = {})
        # see what branch is checked out and where we are branched from
        puts "Current Branch: #{Toolshed::Git.branch_name}"
        puts "Branched From: #{Toolshed::Git.branched_from}"

        pivotal_tracker = nil
        if (Toolshed::Client.use_pivotal_tracker)
          # load up the project information for pivotal tracker
          print "Project ID (Default: #{Toolshed::Client.default_pivotal_tracker_project_id})? "
          project_id = $stdin.gets.chomp.strip
          if (project_id == '')
            project_id = Toolshed::Client.default_pivotal_tracker_project_id
          end
          pivotal_tracker = Toolshed::PivotalTracker.new({ project_id: project_id, username: Toolshed::PivotalTracker.username, password: Toolshed::PivotalTracker.password })
        end

        pt_ticket_title = ''
        if (Toolshed::Client.use_pivotal_tracker)
          # load up the story information from PivotalTracker
          default_story_id = Toolshed::PivotalTracker::story_id_from_branch_name(Toolshed::Git.branch_name)
          print "Story ID (Default: #{default_story_id})? "
          story_id = $stdin.gets.chomp.strip
          if (story_id == '')
            story_id = default_story_id
          end

          pivotal_tracker_result = pivotal_tracker.story_information(story_id)

          pt_ticket_title = pivotal_tracker_result.name
          pt_ticket_title = pt_ticket_title.gsub("'", "").gsub("\"", "")
        end

        if (Toolshed::Client.git_tool == 'github')
          # create the pull request
          begin
            github = Toolshed::Git::Github.new({ username: Toolshed::Git::Github.username, password: Toolshed::Git::Github.password })
            github_pull_request_result = github.create_pull_request(pt_ticket_title, pivotal_tracker_result.url)

            if (Toolshed::Client.use_pivotal_tracker)
              print "Would you like to add a note to PivotalTracker with the pull request URL(y/n)? "
              update_pt_info = $stdin.gets.chomp.strip

              if (update_pt_info == 'y')
                result = pivotal_tracker.add_note(story_id, github_pull_request_result["html_url"])
                result = pivotal_tracker.update_story_state(story_id, Toolshed::PivotalTracker::STORY_STATUS_DEFAULT)
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
