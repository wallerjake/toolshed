require 'toolshed/commands/base'
require 'toolshed/git'

module Toolshed
  module Commands
    class CreateTicketComment < Base

      def initialize(options={})
        super(options)
      end

      def self.cli_options
        {
          banner: 'Usage: create_ticket_comment [options]',
          options: {
            use_defaults: {
              short_on: '-d'
            }
          }
        }
      end

      def execute(args, options = {})
        ticket_tracker_class =  Object.const_get("Toolshed::TicketTracking::#{Toolshed::Client.ticket_tracking_tool.camel_case}")

        options = use_ticket_tracker_project_id(options)
        options = use_ticket_tracker_project_name(options)

        default_ticket_id = Toolshed::TicketTracking::story_id_from_branch_name(git.branch_name)
        ticket_id = read_user_input("Ticket ID (Default: #{default_ticket_id}):", options.merge!({ default: default_ticket_id }))
        options.merge!({ ticket_id: ticket_id })

        ticket_tracker = ticket_tracker_class.create_instance(options)

        puts "Using Project: #{ticket_tracker_project_id}" if use_project_id
        puts "Using Ticket: #{ticket_id}"

        puts "Note? "
        note_text = $stdin.gets.chomp.strip

        begin
          result = ticket_tracker.add_note(note_text)
          if (result)
            puts "Comment has been added to ticket"
          else
            puts "Unable to add comment #{result.inspect}"
          end
        rescue => e
          puts e.message
          exit
        end
      end

      def git
        Toolshed::Git.new
      end
    end
  end
end
