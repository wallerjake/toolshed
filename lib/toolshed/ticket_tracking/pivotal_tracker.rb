module Toolshed
  module TicketTracking
    class PivotalTracker < Base
      include HTTParty

      DEFAULT_COMPLETED_STATUS = 'finished'
      USE_PROJECT_ID = true

      attr_accessor :project_id, :token, :story, :default_pull_request_title_format

      def initialize(options={})
        username = Toolshed::Client.instance.pivotal_tracker_username
        password = Toolshed::Client.instance.pivotal_tracker_password
        self.default_pull_request_title_format = Toolshed::Client.instance.default_pull_request_title_format ||= "[title]"

        unless (options[:username].nil?)
          username = options[:username]
        end

        unless (options[:password].nil?)
           password = options[:password]
        end

        self.token = ::PivotalTracker::Client.token(username, password)

        self.project_id = (options[:project_id].nil?) ? Toolshed::Client.instance.default_pivotal_tracker_project_id : options[:project_id]
        @pt_project = ::PivotalTracker::Project.find(self.project_id)
        self.story = @pt_project.stories.find(options[:ticket_id])
      end

      def ticket
        self.story
      end

      def add_note(note_text)
        results = self.story.notes.create(text: note_text)
      end

      def update_ticket_status(current_state, options={})
        options.merge!({
          :headers => {
              "X-TrackerToken"  => self.token,
              "User-Agent"      => "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_8_2) AppleWebKit/537.17 (KHTML, like Gecko) Chrome/24.0.1309.0 Safari/537.17",
              "Content-Type"    => "application/json",
          },
          body: {
            current_state: current_state
          }.to_json
        })

        response = HTTParty.put("#{Toolshed::Client::PIVOTAL_TRACKER_BASE_API_URL}projects/#{self.project_id}/stories/#{self.story.id}", options).response
        response = JSON.parse(response.body)

        if (response["error"].nil?)
          response
        else
          raise "validation errors #{response.inspect}"
        end
      end

      def default_title
        default_title_text = self.default_pull_request_title_format
        self.default_pull_request_title_format.scan(/(\[\w*\])/).each do |replacement_element|
          default_title_text = default_title_text.gsub(replacement_element.first.to_s, self.send(replacement_element.first.to_s.gsub("[", "").gsub("]", "")))
        end
        default_title_text
      end

      def attribute_value(attribute)
        value = self.story.send(attribute)
        self.clean(value) if attribute == 'title'
        value
      end

      class << self
        def username
          username = Toolshed::Client.instance.pivotal_tracker_username
          if (username.nil?)
            # prompt to ask for username
            puts "PivotalTracker username? "
            username = $stdin.gets.chomp.strip
          end

          return username
        end

        def password
          password = Toolshed::Client.instance.pivotal_tracker_password
          if (password.nil?)
            # prompt to ask for password
            system "stty -echo"
            puts "PivotalTracker password? "
            password = $stdin.gets.chomp.strip
            system "stty echo"
          end

          return password
        end

        def create_instance(options={})
          unless (options.has_key?(:project_id))
            raise 'Unable to use PivotalTracker as project id was not supplied'
          end

          unless (options.has_key?(:ticket_id))
            raise 'Unable to use PivotalTracker as story id was not supplied'
          end

          Toolshed::TicketTracking::PivotalTracker.new({
            project_id: options[:project_id],
            username:   Toolshed::TicketTracking::PivotalTracker.username,
            password:   Toolshed::TicketTracking::PivotalTracker.password,
            ticket_id:   options[:ticket_id],
          })
        end
      end
    end
  end
end
