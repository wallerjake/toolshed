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
  branched_from_remote_name: [branched_from_remote_name] (required)
  branched_from_user: [branched_from_username] (required)
  branched_from_repo_name: [branched_from_repo_name] (required)
  push_from_user: [push_from_yourself] (required)
  push_to_myself: [push_to_yourself] (required)
  use_git_submodules: false (optional)
  git_tool: github (optional default `github`)
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
  --ticket_system "pivotal_tracker"]    # Optionally pass in your ticket system this can also be set in your config as ticket_tracking_tool
get_pivotal_tracker_story_information   # Get the ticket information from a PivotalTracker story based on project_id and story_id
create_pivotal_tracker_note             # Create a note for a specific PivotalTracker story based on project_id and story_id
update_pivotal_tracker_story_status     # Update the status of PivotalTracker story
create_git_branch                       # Create a git branch and push it to your local repository
checkout_git_branch                     # Checkout a git branch and update the submodules if you use them
push_git_branch                         # Push your current working branch to your own repository
get_daily_time_update                   # Get a daily update from your time tracking toolset currently harvest is supported
EOF
end

if $0.split("/").last == 'toolshed'
  options = {}

  global = OptionParser.new do |opts|
    opts.on("-u", "--github_username [ARG]") do |username|
      Toolshed::Client.github_username = username
    end
    opts.on("-p", "--github_password [ARG]") do |password|
      Toolshed::Client.github_password = password
    end
    opts.on("-u", "--pivotal_tracker_username [ARG]") do |username|
      Toolshed::Client.pivotal_tracker_username = username
    end
    opts.on("-p", "--pivotal_tracker_password [ARG]") do |password|
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
      opts.on("--ticket_system [ARG]") do |opt|
        Toolshed::Client.ticket_tracking_tool = opt.downcase
      end
    end,
    'push_git_branch' => OptionParser.new do |opts|
      opts.on("--force [ARG]") do |opt|
        Toolshed::Client.git_force = true
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
