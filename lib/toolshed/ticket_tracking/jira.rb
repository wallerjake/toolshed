module Toolshed
  module TicketTracking
    class Jira
      extend TicketTracking
      include HTTParty

      USE_PROJECT_NAME = true

      attr_accessor :project, :client, :owner, :ticket

      def initialize(options={})
        username        = Toolshed::Client::ticket_tracker_username
        password        = Toolshed::Client::ticket_tracker_password
        self.owner      = Toolshed::Client::ticket_tracker_owner

        unless (options[:username].nil?)
          username = options[:username]
        end

        unless (options[:password].nil?)
           password = options[:password]
        end

        self.client = JIRA::Client.new({
          username:     username,
          password:     password,
          site:         "https://#{self.owner}.atlassian.net",
          context_path: '',
          auth_type:    :basic,
          use_ssl:      true,
        })
        self.project  = self.client.Project.find(options[:project])
        self.ticket   = self.client.Issue.find(options[:ticket_id])
      end

      #
      # Instance methods
      #
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

      def title
        self.ticket.summary
      end

      def url
        "https://#{self.owner}.atlassian.net/browse/#{self.ticket.key}"
      end

      #
      # Class methods
      #
      def self.username
        username = Toolshed::Client::ticket_tracker_username
        if (username.nil?)
          # prompt to ask for username
          puts "Jira username? "
          username = $stdin.gets.chomp.strip
        end
      end

      def self.password
        password = Toolshed::Client::ticket_tracker_password
        if (password.nil?)
          # prompt to ask for password
          system "stty -echo"
          puts "Jira password? "
          password = $stdin.gets.chomp.strip
          system "stty echo"
        end

        password
      end

      def self.create_instance(options={})
        unless (options.has_key?(:project))
          raise 'Unable to use Jira as project name was not supplied'
        end

        unless (options.has_key?(:ticket_id))
          raise 'Unable to use Jira as ticket id was not supplied'
        end

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
