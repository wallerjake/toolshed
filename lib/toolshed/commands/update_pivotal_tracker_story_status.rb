module Toolshed
  module Commands
    class UpdatePivotalTrackerStoryStatus
      STORY_STATUS_DEFAULT = 'finished'

      def execute(args, options = {})
        print "Project ID (Default: #{Toolshed::Client.default_pivotal_tracker_project_id})? "
        project_id = $stdin.gets.chomp.strip
        if (project_id == '')
          project_id = Toolshed::Client.default_pivotal_tracker_project_id
        end

        pivotal_tracker = Toolshed::PivotalTracker.new({ project_id: project_id, username: Toolshed::PivotalTracker.username, password: Toolshed::PivotalTracker.password })
        github = Toolshed::Github.new

        default_story_id = Toolshed::PivotalTracker::story_id_from_branch_name(github.branch_name)
        print "Story ID (Default: #{default_story_id})? "
        story_id = $stdin.gets.chomp.strip
        if (story_id == '')
          story_id = default_story_id
        end

        print "Status (Default: #{Toolshed::PivotalTracker::STORY_STATUS_DEFAULT})? "
        story_status = $stdin.gets.chomp.strip
        if (story_status == '')
          story_status = Toolshed::PivotalTracker::STORY_STATUS_DEFAULT
        end

        begin
          result = pivotal_tracker.update_story_state(story_id, story_status)
          result.each do |key, value|
            puts "#{key}: #{value}"
          end
        rescue => e
          puts e.message
          exit
        end
      end
    end
  end
end
