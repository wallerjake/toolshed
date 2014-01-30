module Toolshed
  module Commands
    class CreateGithubPullRequest
      def execute(args, options = {})
        pull_request = Toolshed::Github.new
        result = pull_request.create_pull_request

        puts "Result: #{result}"
      end
    end
  end
end
