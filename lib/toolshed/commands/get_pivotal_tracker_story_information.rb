module Toolshed
  module Commands
    class GetPivotalTrackerStoryInformation
      def execute(args, options = {})
        begin
          print "Project ID (Default: #{Toolshed::Client.default_pivotal_tracker_project_id})? "
          project_id = $stdin.gets.chomp.strip
          if (project_id == '')
            project_id = Toolshed::Client.default_pivotal_tracker_project_id
          end

          pivotal_tracker = Toolshed::TicketTracking::PivotalTracker.new({
              project_id: project_id,
              username: Toolshed::TicketTracking::PivotalTracker.username,
              password: Toolshed::TicketTracking::PivotalTracker.password,
          })

          default_story_id = Toolshed::TicketTracking::PivotalTracker::story_id_from_branch_name(Toolshed::Git::Base.branch_name)
          print "Story ID (Default: #{default_story_id})? "
          story_id = $stdin.gets.chomp.strip
          if (story_id == '')
            story_id = default_story_id
          end

          result = pivotal_tracker.story_information(story_id)
          result.instance_variables.each do |name, value|
            puts "#{name}: #{result.instance_variable_get(name).inspect}"
          end
          exit
        rescue => e
          puts e.message
          exit
        end
      end
    end
  end
end
