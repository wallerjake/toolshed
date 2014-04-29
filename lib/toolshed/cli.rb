module Toolshed
  class CommandNotFound < RuntimeError
  end

  class CLI
    def execute(command_name, args, options={})
      Toolshed::Client.load_credentials_if_necessary
      command = commands[command_name]
      if command
        begin
          command.new.execute(args, options)
        rescue Toolshed::Error => e
          puts "An error occurred: #{e.message}"
        rescue RuntimeError => e
          puts "An error occurred: #{e.message}"
        end
      else
        raise CommandNotFound, "Unknown command: #{command_name}"
      end
    end

    def commands
      {
        'create_pull_request'                   => Toolshed::Commands::CreatePullRequest,
        'create_pivotal_tracker_note'           => Toolshed::Commands::CreatePivotalTrackerNote,
        'ticket_information'                    => Toolshed::Commands::TicketInformation,
        'update_pivotal_tracker_story_status'   => Toolshed::Commands::UpdatePivotalTrackerStoryStatus,
        'create_branch'                         => Toolshed::Commands::CreateBranch,
        'checkout_branch'                       => Toolshed::Commands::CheckoutBranch,
        'push_branch'                           => Toolshed::Commands::PushBranch,
        'get_daily_time_update'                 => Toolshed::Commands::GetDailyTimeUpdate,
        'list_branches'                         => Toolshed::Commands::ListBranches,
        'delete_branch'                         => Toolshed::Commands::DeleteBranch,
        'create_ticket_comment'                 => Toolshed::Commands::CreateTicketComment,
      }
    end
  end
end

require 'toolshed/commands/create_pull_request'
require 'toolshed/commands/create_pivotal_tracker_note'
require 'toolshed/commands/ticket_information'
require 'toolshed/commands/update_pivotal_tracker_story_status'
require 'toolshed/commands/create_branch'
require 'toolshed/commands/checkout_branch'
require 'toolshed/commands/push_branch'
require 'toolshed/commands/get_daily_time_update'
require 'toolshed/commands/get_daily_time_update'
require 'toolshed/commands/list_branches'
require 'toolshed/commands/delete_branch'
require 'toolshed/commands/create_ticket_comment'
