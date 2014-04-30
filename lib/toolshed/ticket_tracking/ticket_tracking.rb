module Toolshed
  module TicketTracking
    def initialize(options={})
    end

    class << self
      def story_id_from_branch_name(branch_name)
        branch_name.split("_")[0]
      end

      def clean(title)
        title.gsub("'", "").gsub("\"", "")
      end
    end
  end
end
