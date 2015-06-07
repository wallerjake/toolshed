require 'jira'

module Toolshed
  module TicketTracking
    class Jira < Base
      include HTTParty

      USE_PROJECT_NAME = true

      attr_accessor :project, :client, :owner, :ticket, :default_pull_request_title_format

      def initialize(options={})
        username = (options[:username].nil?) ? Toolshed::Client.instance.ticket_tracker_username : options[:username]
        password = (options[:password].nil?) ? Toolshed::Client.instance.ticket_tracker_password : options[:password]

        self.owner      = Toolshed::Client.instance.ticket_tracker_owner
        self.default_pull_request_title_format = Toolshed::Client.instance.default_pull_request_title_format ||= "[summary]"

        self.client = JIRA::Client.new({
          username:     username,
          password:     password,
          site:         "https://#{self.owner}.atlassian.net",
          context_path: '',
          auth_type:    :basic,
          use_ssl:      true,
        })

        self.project = self.client.Project.find(options[:project])
        self.ticket = self.client.Issue.find(options[:ticket_id])
      end

      def add_note(note_text)
        issue = self.ticket.comments.build
        issue.save({ 'body' => note_text })
      end

      def update_ticket_status(status, options={})
        available_statuses

        transition = self.ticket.transitions.build
        transition.save({ 'transition' => { "id" => transition_status_id_by_status(status) } })
      end

      def available_statuses
        self.client.Transition.all(issue: self.ticket)
      end

      def transition_status_id_by_status(status)
        self.available_statuses.each do |transition_status|
          if (status == transition_status.name)
            return transition_status.id
          end
        end

        raise "Unable to find available status"
      end

      def default_title
        default_title_text = self.default_pull_request_title_format
        self.default_pull_request_title_format.scan(/(\[\w*\])/).each do |replacement_element|
          default_title_text = default_title_text.gsub(replacement_element.first.to_s, self.send(replacement_element.first.to_s.gsub("[", "").gsub("]", "")))
        end
        default_title_text
      end

      def attribute_value(attribute)
        self.ticket.send(attribute)
      end

      def url
        "https://#{self.owner}.atlassian.net/browse/#{self.ticket.key}"
      end

      class << self
        def username
          return Toolshed::Client.instance.ticket_tracker_username unless Toolshed::Client.instance.ticket_tracker_username.nil?

          # prompt to ask for username
          puts "Jira username? "
          username = $stdin.gets.chomp.strip
        end

        def password
          return Toolshed::Client.instance.ticket_tracker_password unless Toolshed::Client.instance.ticket_tracker_password.nil?

          # prompt to ask for password
          system "stty -echo"
          puts "Jira password? "
          password = $stdin.gets.chomp.strip
          system "stty echo"
        end

        def create_instance(options={})
          raise 'Unable to use Jira as project name was not supplied' unless (options.has_key?(:project))
          raise 'Unable to use Jira as ticket id was not supplied' unless (options.has_key?(:ticket_id))

          jira = Toolshed::TicketTracking::Jira.new({
            project:    options[:project],
            username:   Toolshed::TicketTracking::Jira.username,
            password:   Toolshed::TicketTracking::Jira.password,
            ticket_id:  options[:ticket_id]
          })
        end
      end
    end
  end
end
