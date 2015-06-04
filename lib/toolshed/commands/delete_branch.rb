require 'toolshed/git'

module Toolshed
  module Commands
    class DeleteBranch
      def self.cli_options
        {
          banner: 'Usage: delete_branch [options]',
          options: {
            branch_name: {
              short_on: '-b',
            }
          }
        }
      end

      def execute(args, options = {})
        branch_name = read_user_input("Ticket ID or branch name:", options)
        git = Toolshed::Git.new
        git.delete_branch(branch_name)
        Toolshed.die
      end

      def read_user_input(message, options)
        return options[:branch_name] if (options.has_key?(:branch_name))

        puts message
        value = $stdin.gets.chomp

        until (!value.empty?)
          puts "Branch name cannot be empty"
          puts message
          value = $stdin.gets.chomp
        end

        value
      end
    end
  end
end
