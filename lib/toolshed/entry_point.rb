require 'toolshed'
require 'toolshed/cli'
require 'toolshed/base'
require 'toolshed/commands/base'
require 'optparse'
require 'singleton'

class EntryPoint
  include Singleton

  attr_accessor :cli

  def initialize
    self.cli = Toolshed::CLI.new
  end

  def execute
    if $0.split("/").last == 'toolshed'
      options = {}

      # @TODO - clean this up as it should really be part of the command it's being used in not globally.
      global = OptionParser.new do |opts|
        opts.on("-u", "--github-username [ARG]") do |username|
          Toolshed::Client.github_username = username
        end
        opts.on("-p", "--github-password [ARG]") do |password|
          Toolshed::Client.github_password = password
        end
        opts.on("-t", "--github-token [ARG]") do |token|
          Toolshed::Client.github_token = token
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
        opts.on('-v', '--version', 'Version') do
          Toolshed::Version.banner
        end
      end

      global.order!
      command = ARGV.shift
      if command.nil?
        usage
      elsif command == 'version'
        Toolshed::Version.banner
        Toolshed.die
      else
        command_class = nil
        command_class_name = command.camel_case
        begin
          require "toolshed/commands/#{command.to_s}"
          command_class = "Toolshed::Commands::#{command_class_name}".split('::').inject(Object) { |o,c| o.const_get c }
        rescue NameError
          command_class = "Toolshed::Commands::#{command_class_name.upcase}".split('::').inject(Object) { |o,c| o.const_get c }
        end
        Toolshed::Commands::Base.parse(command, command_class.cli_options)
      end
    end
  end

  def usage
    $stdout.puts <<EOF
Please see toolshedrc.sample to create your toolshedrc settings file.

Available Commands:

  checkout_branch
  create_branch
  create_pivotal_tracker_note
  create_pull_request
  create_ticket_comment
  delete_branch
  get_daily_time_update
  list_branches
  push_branch
  rename_branch
  ssh
  ticket_information
  update_pivotal_tracker_story_status
  update_ticket_status
EOF
  end
end
