require 'toolshed/git'

module Toolshed
  module Commands
    class UpdateTicketStatus
      def branch
        @branch ||= Toolshed::Git::Branch.new
      end

      def execute(args, options = {})
        ticket_tracker_class =  Object.const_get("Toolshed::TicketTracking::#{Toolshed::Client.instance.ticket_tracking_tool.camel_case}")

        use_project_id = Object.const_get("#{ticket_tracker_class}::USE_PROJECT_ID") rescue false
        if use_project_id
          ticket_tracker_project_id = read_user_input_project("Project ID (Default: #{Toolshed::Client.instance.default_pivotal_tracker_project_id}):", options.merge!({ default: Toolshed::Client.instance.default_pivotal_tracker_project_id }))
          options.merge!({ project_id: ticket_tracker_project_id })
        end

        use_project_name = Object.const_get("#{ticket_tracker_class}::USE_PROJECT_NAME") rescue false
        if use_project_name
          ticket_tracker_project_name = read_user_input_project("Project Name (Default: #{Toolshed::Client.instance.default_ticket_tracker_project}):", options.merge!({ default: Toolshed::Client.instance.default_ticket_tracker_project }))
          options.merge!({ project: ticket_tracker_project_name })
        end

        default_ticket_id = Toolshed::TicketTracking::story_id_from_branch_name(branch.name)
        ticket_id = read_user_input_ticket_id("Ticket ID (Default: #{default_ticket_id}):", options.merge!({ default: default_ticket_id }))
        options.merge!({ ticket_id: ticket_id })

        ticket_tracker = ticket_tracker_class.create_instance(options)

        status = read_user_input_status("Status:")

        begin
          result = ticket_tracker.update_ticket_status(status)
          puts result
        rescue => e
          puts e.message
          exit
        end
      end

      def read_user_input_project(message, options)
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

      def read_user_input_status(message)
        puts message
        value = $stdin.gets.chomp

        until !value.nil? && !value.empty?
          puts "Status must be passed in"
          puts message
          value = $stdin.gets.chomp
        end
      end
    end
  end
end
