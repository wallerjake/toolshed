module Toolshed
  module Commands
    class PushBranch
      def execute(args, options = {})
        Toolshed::Git::Base.push(options)
      end
    end
  end
end
