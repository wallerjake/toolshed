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

  use_pivotal_tracker: true (required)
  pivotal_tracker_username: [pivotal_tracker_username] (not required)
  pivotal_tracker_password: [pivotal_tracker_password] (not required)
  default_pivotal_tracker_project_id: [project_id] (not required)
  github_username: [github_username] (not required)
  github_password: [github_password] (not required)
  branched_from_remote_name: [branched_from_remote_name] (required)
  branched_from_user: [branched_from_username] (required)
  branched_from_repo_name: [branched_from_repo_name] (required)
  push_from_user: [push_from_yourself] (required)
  push_to_myself: [push_to_yourself] (required)

== Commands

All commands are executed as toolshed [options] command [command-options] args

The following commands are available:

help                                    # show this usage
create_github_pull_request              # create a github pull request based on the branch you currently have checked out
get_pivotal_tracker_story_information   # Get the ticket information from a PivotalTracker story based on project_id and story_id
create_pivotal_tracker_note             # Create a note for a specific PivotalTracker story based on project_id and story_id
update_pivotal_tracker_story_status     # Update the status of PivotalTracker story
create_git_branch                       # Create a git branch and push it to your local repository
checkout_git_branch                     # Checkout a git branch and update the submodules if you use them
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
    opts.on("-d", "--debug [ARG]", "Debug") do
      Toolshed::Client.debug = true
    end
    opts.on("-h", "--help", "Help") do
      usage
    end
  end

  subcommands = {}

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
