module Toolshed
  module Commands
    class CreateGitBranch
      def execute(args, options = {})
          print "Branch text? "
          branch_name = $stdin.gets.chomp

          print "Branch from? "
          branch_from = $stdin.gets.chomp

          git_submodule_command = ''
          if (Toolshed::Client.use_git_submodules)
            print "Update Submodules (y/n)? "
            update_submodules = $stdin.gets.chomp
            if (update_submodules == 'y')
              git_submodule_command = "git submodule update --init;"
            end
          end

          branch_name = branch_name.strip.downcase.tr(" ", "_").gsub("-", "").gsub("&", "").gsub("/", "_").gsub(".", "_").gsub("'", "").gsub("__", "_").gsub(":", "")
          output_text = "git remote update; git checkout -b #{branch_name} #{Toolshed::Client.branched_from_remote_name}/#{branch_from}; #{git_submodule_command} git push #{Toolshed::Client.push_to_myself} #{branch_name}"

          puts "Creating branch.."
          system(output_text)
      end
    end
  end
end
