module Toolshed
  module Commands
    class DeleteBranch
      def execute(args, options = {})
        print "Ticket ID or Branch Name? "
        ticket_id = $stdin.gets.chomp

        Toolshed::Git::Base.delete(ticket_id)
      end
    end
  end
end
