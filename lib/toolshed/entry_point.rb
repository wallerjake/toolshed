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
      if command_parts.length == 0
        usage
      elsif command_parts[0] == 'version'
        Toolshed::Version.banner
        Toolshed.die
      else
        command_class = default_command_class_string
        attempts = 0
        begin
          require "toolshed/commands/#{command_parts.join('/')}"
          command_class = command_class.split('::').inject(Object) { |o,c| o.const_get c }
        rescue NameError => e
          name_error_name = e.message.sub('wrong constant name ', '')
          name_error_name = e.message.sub('uninitialized constant ', '')
          command_class = command_class.sub(name_error_name, name_error_name.upcase)
          attempts += 1
          retry unless attempts > command_parts.length
        end
        Toolshed::Commands::Base.parse(command_class, command_class.cli_options)
      end
    end
  end

  def command_parts
    @command_parts ||= begin
      command_parts = []
      arguments_left = true
      until !arguments_left
        if ARGV.first.nil? || ARGV.first.start_with?('--')
        #if argument.nil? || argument.start_with?('--')
          arguments_left = false
        else
          command_parts << ARGV.shift
        end
      end
      command_parts
    end
  end

  def default_command_class_string
    command_class = "Toolshed::Commands"
    command_parts.each do |command_part|
      command_class = "#{command_class}::#{command_part.capitalize}"
    end
    command_class
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
