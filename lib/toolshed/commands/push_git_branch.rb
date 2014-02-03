module Toolshed
  module Commands
    class PushGitBranch
      def execute(args, options = {})
          branch_name = `git rev-parse --abbrev-ref HEAD`
          system("git push #{Toolshed::Client.push_to_myself} #{branch_name}")
      end
    end
  end
end
