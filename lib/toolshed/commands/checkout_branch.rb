module Toolshed
  module Commands
    class CheckoutBranch
      def execute(args, options = {})
        print "Ticket ID or Branch Name? "
        ticket_id = $stdin.gets.chomp

        Toolshed::Git::Base.checkout(ticket_id)
      end
    end
  end
end
