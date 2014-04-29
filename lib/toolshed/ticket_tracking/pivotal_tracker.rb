module Toolshed
  module TicketTracking
    class PivotalTracker
      extend TicketTracking
      include HTTParty

      DEFAULT_COMPLETED_STATUS = 'finished'
      USE_PROJECT_ID = true

      attr_accessor :project_id, :token

      def initialize(options={})
        username = Toolshed::Client::pivotal_tracker_username
        password = Toolshed::Client::pivotal_tracker_password

        unless (options[:username].nil?)
          username = options[:username]
        end

        unless (options[:password].nil?)
           password = options[:password]
        end

        self.token = ::PivotalTracker::Client.token(username, password)

        self.project_id = (options[:project_id].nil?) ? Toolshed::Client.default_pivotal_tracker_project_id : options[:project_id]
        @pt_project = ::PivotalTracker::Project.find(self.project_id)
      end

      #
      # Instance methods
      #
      def story_information(story_id)
        return @pt_project.stories.find(story_id)
      end

      def add_note(story_id, note_text)
        story = @pt_project.stories.find(story_id)
        results = story.notes.create(text: note_text)
      end

      def update_ticket_status(story_id, current_state, options={})
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

        response = HTTParty.put("#{Toolshed::Client::PIVOTAL_TRACKER_BASE_API_URL}projects/#{self.project_id}/stories/#{story_id}", options).response
        response = JSON.parse(response.body)

        if (response["error"].nil?)
          response
        else
          raise "validation errors #{response.inspect}"
        end
      end

      def title(ticket_id)
        self.clean(self.story_information(ticket_id).name)
      end

      def url(ticket_id)
        self.story_information(ticket_id).url
      end

      #
      # Class methods
      #
      def self.story_id_from_branch_name(branch_name)
        story_id = branch_name.split("_")[0]
      end

      def self.username
        username = Toolshed::Client::pivotal_tracker_username
        if (username.nil?)
          # prompt to ask for username
          puts "PivotalTracker username? "
          username = $stdin.gets.chomp.strip
        end

        return username
      end

      def self.password
        password = Toolshed::Client::pivotal_tracker_password
        if (password.nil?)
          # prompt to ask for password
          system "stty -echo"
          puts "PivotalTracker password? "
          password = $stdin.gets.chomp.strip
          system "stty echo"
        end

        return password
      end

      #
      # Get the pivotal tracker object based off of the project_id
      #
      def self.create_instance(options={})
        unless (options.has_key?(:project_id))
          raise 'Unable to use PivotalTracker as project id was not supplied'
        end

        pivotal_tracker = Toolshed::TicketTracking::PivotalTracker.new({ project_id: options[:project_id], username: Toolshed::TicketTracking::PivotalTracker.username, password: Toolshed::TicketTracking::PivotalTracker.password })
      end

      def self.clean(title)
        title.gsub("'", "").gsub("\"", "")
      end
    end
  end
end
