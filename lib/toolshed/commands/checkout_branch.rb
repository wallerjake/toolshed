module Toolshed
  module Commands
    class CheckoutBranch
      def execute(args, options = {})
        branch_name = options[:branch_name]
        unless (options[:branch_name])
          print "Ticket ID or Branch Name? "
          branch_name = $stdin.gets.chomp
        end

        Toolshed::Git::Base.checkout(branch_name)
      end
    end
  end
end
