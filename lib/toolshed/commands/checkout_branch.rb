module Toolshed
  module Commands
    class CheckoutBranch
      def execute(args, options = {})
        branch_name = options[:branch_name]
        unless (options[:branch_name])
          branch_name = self.read_user_input("Ticket ID or Branch Name? ")
        end

        branch_name = Toolshed::Git::Base.checkout(branch_name)
        puts "Switched to '#{branch_name}'"
      end

      def read_user_input(message)
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
