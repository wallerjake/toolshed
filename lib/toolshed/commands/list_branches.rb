module Toolshed
  module Commands
    class ListBranches
      def self.cli_options
        {
          banner: 'Usage: list_branches [options]',
          options: {
            repository_name: {
              short_on: '-r',
            },
          }
        }
      end

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
