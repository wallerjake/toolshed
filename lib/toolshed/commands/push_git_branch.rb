module Toolshed
  module Commands
    class PushGitBranch
      def execute(args, options = {})
        force_command = ''
        if (Toolshed::Client.git_force)
          force_command = " --force"
        end
        system("git push #{Toolshed::Client.push_to_remote_name} #{Toolshed::Git::Base.branch_name} #{force_command}")
      end
    end
  end
end
