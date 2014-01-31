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

          pivotal_tracker = Toolshed::PivotalTracker.new({ project_id: project_id})
          github = Toolshed::Github.new

          default_story_id = Toolshed::PivotalTracker::story_id_from_branch_name(github.branch_name)
          print "Story ID (Default: #{default_story_id})? "
          story_id = $stdin.gets.chomp.strip
          if (story_id == '')
            story_id = default_story_id
          end

          result = pivotal_tracker.story_information(story_id)
          puts "Name: #{result.name}"
          puts "Url: #{result.url}"
          puts "Description: #{result.description}"
          exit
        rescue => e
          puts e.message
          exit
        end
      end
    end
  end
end
