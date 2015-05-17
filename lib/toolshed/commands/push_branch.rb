module Toolshed
  module Commands
    class PushBranch
      def self.cli_options
        {
          force: {
            on: '--force',
            name: :force_command,
            default: true
          },
          branch_name: {
            on: '--branch-name [ARGV]',
            name: :branch_name
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
