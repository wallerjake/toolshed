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
        git = Toolshed::Git.new
        git.list_branches
        Toolshed.die
      end
    end
  end
end
