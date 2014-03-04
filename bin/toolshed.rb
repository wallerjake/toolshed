#!/usr/bin/env ruby

$:.unshift(File.dirname(__FILE__) + '/../lib')
require 'toolshed'
require 'toolshed/cli'

cli = Toolshed::CLI.new

require 'optparse'

def usage
  $stderr.puts <<EOF
Command line tool for toolshed. More information about toolshed can
be found at https://github.com/wallerjake/toolshed

Before using this tool you should create a file called .toolshedrc in your projects directory or home directory if you want to use the settings globally.
Note that it will only read one file which ever file is closest to the directory you are in. Then and add the following to that file:

  ticket_tracking_tool: 'pivotal_tracker' (required)
  pivotal_tracker_username: [pivotal_tracker_username] (optional)
  pivotal_tracker_password: [pivotal_tracker_password] (optional)
  default_pivotal_tracker_project_id: [project_id] (optional)

  github_username: [github_username] (optional)
  github_password: [github_password] (optional)
  git_tool: github (optional default `github`)
  use_git_submodules: false (optional default `false`)
  pull_from_remote_name: [pull_from_remote_name] (required)
  pull_from_repository_user: [pull_from_repository_username] (required)
  pull_from_repository_name: [pull_from_repository_name] (required)
  push_to_repository_user: [push_to_repository_user] (required)
  push_to_repository_name: [push_to_repository_name] (required)
  push_to_remote_name: [push_to_remote_name] (required)

  time_tracking_username: [username] (optional)
  time_tracking_password: [password] (optional)
  time_tracking_owner: [owner] (optional)
  time_tracking_default_project_id: [project_id] (optional)
  time_tracking_tool: [tool] (optional)

== Commands

All commands are executed as toolshed [options] command [command-options] args

The following commands are available:

help                                    # show this usage
create_pull_request [                   # create a github pull request based on the branch you currently have checked out
  --tool "github",                      # Optionally pass in your specific tool this can also be set in your config as git_tool
  --ticket-system "pivotal_tracker"     # Optionally pass in your ticket system this can also be set in your config as ticket_tracking_tool
  --use-defaults "true"                 # use defaults instead of getting prompts if you don't want to edit your body or title
  --title "Pull Request Title"          # Title you want to use with the pull request
  --body "Pull Request Body"            # Body you want to use with the pull request
]
ticket_information [                    # Get the ticket information from a story based on ticket system configuration
  --use-defaults="true|false"           # If you want to use defaults ticket_id is taken from branch_name otherwise configuration is used
  --clipboard="true|false"              # Copy the output to the system clipboard (Mac OSx) tested
  --field="field_name"                  # The field you want to either output or copy to your clipboard
  --formatted-string="{name} - {url}    # Pass a formatted string in ticket name and url and it will return that string replaced by the actual value
]
create_pivotal_tracker_note             # Create a note for a specific PivotalTracker story based on project_id and story_id
update_pivotal_tracker_story_status     # Update the status of PivotalTracker story
create_branch [                         # Create a branch default (git) and push it to your local repository
  --branch-name "123_test"              # The branch name standard it [ticket_id]_description
  --branch-from "master"                # What branch do you want to branch from
]
checkout_branch [                       # Checkout a branch [default git] and update the submodules if true
  --branch-name "123"                   # Branch name or part of the branch name you want to checkout
]
push_branch [                           # Push your current working branch to your own repository
  --force                               # Push your current working branch up with --force after
  --branch-name "another"               # Push this specific branch up instead of your current working branch
]
get_daily_time_update [                 # Get a daily update from your time tracking toolset currently harvest is supported
  --format="html|text"                  # Format you want if you want html it will open html page in broswer otherwise puts out plain text
]
list_branches [                         # List branches for your remote repository
  --repository-name "depot"             # The repository name you want to list branches for if not passed pull_from_repository_name is used
]
delete_branch [                         # Delete a branch both locally and to your push to remote
  --branch-name "134_mybranch" | "134"  # Either the full branch name or some unique string in the branch i.e. ticket id
]
EOF
end

if $0.split("/").last == 'toolshed'
  options = {}

  global = OptionParser.new do |opts|
    opts.on("-u", "--github-username [ARG]") do |username|
      Toolshed::Client.github_username = username
    end
    opts.on("-p", "--github-password [ARG]") do |password|
      Toolshed::Client.github_password = password
    end
    opts.on("-u", "--pivotal-tracker-username [ARG]") do |username|
      Toolshed::Client.pivotal_tracker_username = username
    end
    opts.on("-p", "--pivotal-tracker-password [ARG]") do |password|
      Toolshed::Client.pivotal_tracker_password = password
    end
    opts.on("-d", "--debug [ARG]") do
      Toolshed::Client.debug = true
    end
    opts.on("-h", "--help", "Help") do
      usage
    end
  end

  subcommands = {
    'create_pull_request' => OptionParser.new do |opts|
      opts.on("--tool [ARG]") do |opt|
        Toolshed::Client.git_tool = opt.downcase
      end
      opts.on("--ticket-system [ARG]") do |opt|
        Toolshed::Client.ticket_tracking_tool = opt.downcase
      end
      opts.on("--use-defaults [ARG]") do |opt|
        Toolshed::Client.use_defaults = opt
      end
      opts.on("--title [ARG]") do |opt|
        options[:title] = opt
      end
      opts.on("--body [ARG]") do |opt|
        options[:body] = opt
      end
    end,
    'create_branch' => OptionParser.new do |opts|
      opts.on("--branch-name [ARG]") do |opt|
        options[:branch_name] = opt
      end
      opts.on("--branch-from [ARG]") do |opt|
        options[:branch_from] = opt
      end
    end,
    'push_branch' => OptionParser.new do |opts|
      opts.on("--force [ARG]") do |opt|
        options[:force_command] = true
      end
      opts.on("--branch-name [ARG]") do |opt|
        options[:branch_name] = opt
      end
    end,
    'list_branches' => OptionParser.new do |opts|
      opts.on("--repository-name [ARG]") do |opt|
        Toolshed::Client.pull_from_repository_name = opt
      end
    end,
    'checkout_branch' => OptionParser.new do |opts|
      opts.on("--branch-name [ARG]") do |opt|
        options[:branch_name] = opt
      end
    end,
    'delete_branch' => OptionParser.new do |opts|
      opts.on("--branch-name [ARG]") do |opt|
        options[:branch_name] = opt
      end
    end,
    'get_daily_time_update' => OptionParser.new do |opts|
      opts.on("--format [ARG]") do |opt|
        options[:format] = opt
      end
    end,
    'ticket_information' => OptionParser.new do |opts|
      opts.on("--use-defaults [ARG]") do |opt|
        options[:use_defaults] = opt
      end
      opts.on("--clipboard [ARG]") do |opt|
        options[:clipboard] = opt
      end
      opts.on("--field [ARG]") do |opt|
        options[:field] = opt
      end
      opts.on("--formatted-string [ARG]") do |opt|
        options[:formatted_string] = opt
      end
    end,
  }

  global.order!
  command = ARGV.shift
  if command.nil? || command == 'help'
    usage
  else
    options_parser = subcommands[command]
    options_parser.order! if options_parser
    begin
      cli.execute(command, ARGV, options)
    rescue Toolshed::CommandNotFound => e
      puts e.message
    end
  end
end
