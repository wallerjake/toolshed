#!/usr/bin/env ruby

$:.unshift(File.dirname(__FILE__) + '/../lib')

require 'toolshed'
require 'toolshed/cli'

cli = Toolshed::CLI.new

require 'optparse'

def usage
  $stderr.puts <<EOF
This is the command line tool for toolshed. More information about toolshed can
be found at https://github.com/wallerjake/toolshed

Before using this tool you should create a file called .toolshed in your home directory
and add the following to that file:

  use_pivotal_tracker: true
  pivotal_tracker_username: [pivotal_tracker_username]
  pivotal_tracker_password: [pivotal_tracker_password]
  default_pivotal_tracker_project_id: [project_id]
  github_username: [github_username]
  github_password: [github_password]
  branched_from_remote_name: [branched_from_remote_name]
  branched_from_user: [branched_from_username]
  branched_from_repo_name: [branched_from_repo_name]
  push_from_user: [push_from_yourself]
  push_to_myself: [push_to_yourself]

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
    opts.on("-u", "--username [ARG]") do |username|
      # Set username here
    end
    opts.on("-p", "--password [ARG]") do |password|
      # Set password here
    end
    opts.on("-d") do
      # Set debug here
    end
  end

  subcommands = { }

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
