module Toolshed
  module Commands
    class CreatePivotalTrackerNote
      def execute(args, options = {})
        print "Project ID (Default: #{Toolshed::Client.instance.default_pivotal_tracker_project_id})? "
        project_id = $stdin.gets.chomp.strip
        if (project_id == '')
          project_id = Toolshed::Client.instance.default_pivotal_tracker_project_id
        end

        pivotal_tracker = Toolshed::TicketTracking::PivotalTracker.new({
            project_id: project_id,
            username: Toolshed::TicketTracking::PivotalTracker.username,
            password: Toolshed::TicketTracking::PivotalTracker.password,
        })

        default_story_id = Toolshed::TicketTracking::PivotalTracker::story_id_from_branch_name(git.branch_name)
        print "Story ID (Default: #{default_story_id})? "
        story_id = $stdin.gets.chomp.strip
        if (story_id == '')
          story_id = default_story_id
        end

        print "Note? "
        note_text = $stdin.gets.chomp.strip

        begin
          result = pivotal_tracker.add_note(story_id, note_text)
          result.instance_variables.each do |name, value|
            puts "#{name}: #{result.instance_variable_get(name).inspect}"
          end
        rescue => e
          puts e.message
          exit
        end
      end

      def git
        Toolshed::Git::Base.new
      end
    end
  end
end
