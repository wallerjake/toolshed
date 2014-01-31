module Toolshed
  module Commands
    class CreatePivotalTrackerNote
      def execute(args, options = {})
        print "Project ID (Default: #{Toolshed::Client.default_pivotal_tracker_project_id})? "
        project_id = $stdin.gets.chomp.strip
        if (project_id == '')
          project_id = Toolshed::Client.default_pivotal_tracker_project_id
        end

        pivotal_tracker = Toolshed::PivotalTracker.new({ project_id: project_id})
        github = Toolshed::Github.new

        default_story_id = Toolshed::PivotalTracker::story_id_from_branch_name(github.branch_name)
        print "Story ID (Default: #{default_story_id})? "
        story_id = $stdin.gets.chomp.strip
        if (story_id == '')
          story_id = default_story_id
        end

        print "Note? "
        note_text = $stdin.gets.chomp.strip

        begin
          result = pivotal_tracker.add_note(story_id, note_text)
          puts result.inspect
        rescue => e
          puts e.message
          exit
        end
      end
    end
  end
end
