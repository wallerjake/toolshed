module Toolshed
  module Commands
    class CreateGithubPullRequest
      def execute(args, options = {})
        pivotal_tracker = nil
        if (Toolshed::Client.use_pivotal_tracker)
          # load up the project information for pivotal tracker
          print "Project ID (Default: #{Toolshed::Client.default_pivotal_tracker_project_id})? "
          project_id = $stdin.gets.chomp.strip
          if (project_id == '')
            project_id = Toolshed::Client.default_pivotal_tracker_project_id
          end

          pivotal_tracker = Toolshed::PivotalTracker.new({ project_id: project_id})
        end

        github = Toolshed::Github.new

        # see what branch is checked out and where we are branched from
        puts "Current Branch: #{github.branch_name}"
        puts "Branched From: #{github.branched_from}"

        pt_ticket_title = ''
        if (Toolshed::Client.use_pivotal_tracker)
          # load up the story information from PivotalTracker
          default_story_id = Toolshed::PivotalTracker::story_id_from_branch_name(github.branch_name)
          print "Story ID (Default: #{default_story_id})? "
          story_id = $stdin.gets.chomp.strip
          if (story_id == '')
            story_id = default_story_id
          end

          pivotal_tracker_result = pivotal_tracker.story_information(story_id)

          pt_ticket_title = pivotal_tracker_result.name
          pt_ticket_title = pt_ticket_title.gsub("'", "").gsub("\"", "")
        end

        # github pull request fields
        print "Github Pull Request Title (Default: #{pt_ticket_title})? "
        github_pull_request_title = $stdin.gets.chomp.strip
        if (github_pull_request_title == '')
          github_pull_request_title = pt_ticket_title
        end

        github_pull_request_default_body = ''
        if (Toolshed::Client.use_pivotal_tracker)
          github_pull_request_default_body = pivotal_tracker_result.url
        end
        print "Body (Default: #{github_pull_request_default_body})? "
        github_pull_request_body = $stdin.gets.chomp.strip
        if (github_pull_request_body == '')
          github_pull_request_body = github_pull_request_default_body
        end

        # create the pull request
        begin
          puts "Running Github Pull Request"
          github_pull_request_result = github.create_pull_request(github_pull_request_title, github_pull_request_body)
          puts "Github Pull Request URL: #{github_pull_request_result["html_url"]}"

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
      end
    end
  end
end
