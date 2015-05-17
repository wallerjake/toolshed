module Toolshed
  module Commands
    class PushBranch
      def self.cli_options
        {
          banner: 'Usage: push_branch [options]',
          options: {
            force_command: {
              short_on: '-f',
              default: true
            },
            branch_name: {
              short_on: '-b'
            }
          }
        }
      end

      def execute(args, options = {})
        branch_name = Toolshed::Git::Base.push(options)
        puts "#{branch_name} has been pushed"
        return
      end
    end
  end
end
