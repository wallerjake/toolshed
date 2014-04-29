module Toolshed
  module TicketTracking
    class Jira
      extend TicketTracking
      include HTTParty

      USE_PROJECT_NAME = true

      attr_accessor :project, :client

      def initialize(options={})
        username  = Toolshed::Client::ticket_tracker_username
        password  = Toolshed::Client::ticket_tracker_password
        owner     = Toolshed::Client::ticket_tracker_owner

        unless (options[:username].nil?)
          username = options[:username]
        end

        unless (options[:password].nil?)
           password = options[:password]
        end

        self.client = JIRA::Client.new({
          username:     username,
          password:     password,
          site:         "https://#{owner}.atlassian.net",
          context_path: '',
          auth_type:    :basic,
          use_ssl:      true,
        })
        self.project = self.client.Project.find(options[:project])
      end

      #
      # Instance methods
      #
      def story_information(ticket_id)
        unless (@issue.nil?)
          return @issue
        end
        @issue = self.client.Issue.find(ticket_id)
      end

      def add_note(ticket_id, note_text)
        issue = self.story_information(ticket_id).comments.build
        issue.save({ 'body' => note_text })
      end

      def update_ticket_status(ticket_id, status, options={})
        available_statuses(ticket_id)

        transition = self.story_information(ticket_id).transitions.build
        transition.save({ 'transition' => { "id" => transition_status_id_by_status(ticket_id, status) } })
      end

      def available_statuses(ticket_id)
        self.client.Transition.all(issue: story_information(ticket_id))
      end

      def transition_status_id_by_status(ticket_id, status)
        self.available_statuses(ticket_id).each do |transition_status|
          if (status == transition_status.name)
            return transition_status.id
          end
        end

        raise "Unable to find available status"
      end

      #
      # Class methods
      #
      def self.story_id_from_branch_name(branch_name)
        branch_name.split("_")[0]
      end

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

      #
      # Get the pivotal tracker object based off of the project_id
      #
      def self.create_instance(options={})
        unless (options.has_key?(:project))
          raise 'Unable to use Jira as project name was not supplied'
        end

        jira = Toolshed::TicketTracking::Jira.new({
          project: options[:project],
          username: Toolshed::TicketTracking::Jira.username,
          password: Toolshed::TicketTracking::Jira.password,
        })
      end

      def self.clean(title)
        title.gsub("'", "").gsub("\"", "")
      end
    end
  end
end
