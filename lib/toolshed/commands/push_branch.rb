module Toolshed
  module Commands
    class PushBranch
      def execute(args, options = {})
        branch_name = Toolshed::Git::Base.push(options)
        puts "#{branch_name} has been pushed"
        return
      end
    end
  end
end
