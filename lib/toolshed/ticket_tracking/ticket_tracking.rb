module Toolshed
  module TicketTracking
    class Base
      def initialize(options={})
      end

      def method_missing(name, *args)
        string_name = name.to_s
        attribute_value(string_name)
      end
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
