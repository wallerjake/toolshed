module Toolshed
  module Commands
    class CheckoutBranch
      def self.cli_options
        {
          banner: 'Usage: checkout_branch [options]',
          options: {
            branch_name: {
              short_on: '-b',
            }
          }
        }
      end

      def execute(args, options = {})
        branch_name = read_user_input("Ticket ID or Branch Name:", options)
        branch_name = Toolshed::Git::Base.checkout(branch_name)
        puts "Switched to '#{branch_name}'"
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
