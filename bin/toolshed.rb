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

== Commands

All commands are executed as toolshed [options] command [command-options] args

The following commands are available:

help                                    # show this usage
create_github_pull_request              # create a github pull request based on the branch you currently have checked out
get_pivotal_tracker_story_information   # Get the ticket information from a PivotalTracker story based on project_id and story_id
create_pivotal_tracker_note             # Create a note for a specific PivotalTracker story based on project_id and story_id
update_pivotal_tracker_story_status     # Update the status of PivotalTracker story
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

  subcommands = {

  }
  #subcommands = {
    #'create_github_pull_request' => 
  #}

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
