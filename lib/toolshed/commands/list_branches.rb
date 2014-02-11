module Toolshed
  module Commands
    class ListBranches
      def execute(args, options = {})
        git = Toolshed::Git::Github.new
        branches = git.list_branches
        branches.each do |branch|
          puts branch['name']
        end
      end
    end
  end
end
