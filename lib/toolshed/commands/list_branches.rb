require 'toolshed/git/git'

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
        git = Toolshed::Git::Base.new
        git.list_branches
      end
    end
  end
end
