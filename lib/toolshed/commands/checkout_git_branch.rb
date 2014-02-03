module Toolshed
  module Commands
    class CheckoutGitBranch
      def execute(args, options = {})
        print "Ticket ID or Branch Name? "
        ticket_id = $stdin.gets.chomp

        branch_name = `git branch | grep \"#{ticket_id}\"`.gsub("*", "").strip

        git_submodule_command = ''
        if (Toolshed::Client.use_git_submodules)
          print "Update Submodules (y/n)? "
          update_submodules = $stdin.gets.chomp
          if (update_submodules == 'y')
            git_submodule_command = "git submodule update --init;"
          end
        end

        system("git checkout #{branch_name}; #{git_submodule_command}")
      end
    end
  end
end
