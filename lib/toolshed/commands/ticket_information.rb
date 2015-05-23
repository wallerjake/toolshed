module Toolshed
  module Commands
    class TicketInformation
      def self.cli_options
        {
          banner: 'Usage: ticket_information [options]',
          options: {
            use_defaults: {
              short_on: '-d'
            },
            clipboard: {
              short_on: '-c'
            },
            field: {
              short_on: '-f'
            },
            formatted_string: {
              short_on: '-fs'
            }
          }
        }
      end

      def execute(args, options = {})
        begin
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

          default_ticket_id = Toolshed::TicketTracking::story_id_from_branch_name(Toolshed::Git::Base.branch_name)
          ticket_id = read_user_input_ticket_id("Story ID (Default: #{default_ticket_id}):", options.merge!({ default: default_ticket_id }))
          options.merge!({ ticket_id: ticket_id })

          ticket_tracker = ticket_tracker_class.create_instance(options)

          if use_project_id
            puts "Using Project: #{ticket_tracker_project_id}"
          end
          puts "Using Ticket: #{ticket_id}"

          result = ticket_tracker.ticket

          if (options[:field])
            field_value = result.send(options[:field])
            if (options[:clipboard])
              Clipboard.copy field_value
            end

            puts field_value
          elsif(options[:formatted_string])
            formatted_string = options[:formatted_string].gsub(/\{(.*?)\}/) { |m| result.send(m.gsub("{", "").gsub("}", "")) }
            if (options[:clipboard])
              Clipboard.copy formatted_string
            end

            puts formatted_string
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
    end
  end
end
