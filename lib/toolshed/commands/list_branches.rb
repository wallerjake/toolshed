require 'toolshed/git'

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
        branch = Toolshed::Git::Branch.new
        branch.list
        Toolshed.die
      end
    end
  end
end
