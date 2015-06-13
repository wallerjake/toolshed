require 'toolshed/git'

require 'highline/import'

module Toolshed
  module Commands
    class DeleteBranch
      attr_accessor :branch

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
        self.branch = Toolshed::Git::Branch.new
        if confirm_delete
          branch.delete(branch_name)
        else
          Toolshed.logger.info "Branch '#{branch.name}' was not deleted."
        end
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

      def confirm_delete
        choices = "yn"
        answer = ask("Are you sure you want to delete #{branch.name} [#{choices}]? ") do |q|
          q.echo      = false
          q.character = true
          q.validate  = /\A[#{choices}]\Z/
        end
        answer == 'y'
      end
    end
  end
end
