module Toolshed
  module Commands
    class TicketInformation
      def execute(args, options = {})
        begin
          ticket_tracker_class =  Object.const_get("Toolshed::TicketTracking::#{Toolshed::Client.ticket_tracking_tool.camel_case}")

          if Object.const_get("#{ticket_tracker_class}::USE_PROJECT_ID")
            ticket_tracker_project_id = read_user_input_project_id("Project ID (Default: #{Toolshed::Client.default_pivotal_tracker_project_id}):", options.merge!({ default: Toolshed::Client.default_pivotal_tracker_project_id }))
            options.merge!({ project_id: ticket_tracker_project_id })
          end

          ticket_tracker = ticket_tracker_class.create_instance(options)

          default_ticket_id = Toolshed::TicketTracking::PivotalTracker::story_id_from_branch_name(Toolshed::Git::Base.branch_name)
          ticket_id = read_user_input_ticket_id("Story ID (Default: #{default_ticket_id}):", options.merge!({ default: default_ticket_id }))

          if Object.const_get("#{ticket_tracker_class}::USE_PROJECT_ID")
            puts "Using Project: #{ticket_tracker_project_id}"
          end
          puts "Using Ticket: #{ticket_id}"

          result = ticket_tracker.story_information(ticket_id)

          if (options[:field])
            field_value = result.send(options[:field])
            if (options[:clipboard])
              Clipboard.copy field_value
            end

            puts field_value
          else
            result.instance_variables.each do |name, value|
              puts "#{name}: #{result.instance_variable_get(name).inspect}"
            end
          end

          return
        rescue => e
          puts e.message
          exit
        end
      end

      def read_user_input_project_id(message, options)
        return options[:default] if (options.has_key?(:use_defaults))

        puts message
        value = $stdin.gets.chomp

        if (value.empty?)
          value = options[:default]
        end

        value
      end

      def read_user_input_ticket_id(message, options)
        return options[:default] if (options.has_key?(:use_defaults))

        puts message
        value = $stdin.gets.chomp

        if (value.empty?)
          value = options[:default]
        end

        value
      end
    end
  end
end
