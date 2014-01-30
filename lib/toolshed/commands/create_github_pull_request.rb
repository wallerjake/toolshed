module Toolshed
  module Commands
    class CreateGithubPullRequest
      def execute(args, options = {})
        github = Toolshed::Github.new

        puts "Current Branch: #{github.branch_name}"
        puts "Branched From: #{github.branched_from}"

        begin
          result = github.create_pull_request("This is my title", "This is the body")
        rescue => e
          puts e.message
          exit
        end

        print "Would you like to load up pivotal tracker information(y/n)? "
        load_pt_info = $stdin.gets.chomp.strip

        if (load_pt_info == 'y')
          default_story_id = Toolshed::PivotalTracker::story_id_from_branch_name(github.branch_name)
          print "Story ID (Default: #{default_story_id})? "
          story_id = $stdin.gets.chomp.strip
          if (story_id == '')
            story_id = default_story_id
          end
        end
      end
    end
  end
end
