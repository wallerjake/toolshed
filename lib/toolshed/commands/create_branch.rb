module Toolshed
  module Commands
    class CreateBranch
      def execute(args, options = {})
        begin
          Toolshed::Git::Base.create_branch_command
        rescue Veto::InvalidEntity => e
          puts "Unable to create branch due to the following errors"
          e.message.each do |key, value|
            puts "#{key}: #{value}"
          end
        end
      end
    end
  end
end
