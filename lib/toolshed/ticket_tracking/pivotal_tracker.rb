module Toolshed
  module TicketTracking
    class PivotalTracker
      extend TicketTracking
      include HTTParty

      DEFAULT_COMPLETED_STATUS = 'finished'

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

      #
      # Get the story id based on what the user enters
      #
      def get_ticket_information
        # load up the story information from PivotalTracker
        story_id = Toolshed::TicketTracking::PivotalTracker::story_id_from_branch_name(Toolshed::Git::Base.branch_name)
        unless (Toolshed::Client.use_defaults)
          print "Story ID (Default: #{story_id})? "
          in_story_id = $stdin.gets.chomp.strip
          unless (in_story_id == '')
            story_id = in_story_id
          end
        end

        story_information = self.story_information(story_id)
      end

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
      def self.create_instance
        # load up the project information for pivotal tracker
        project_id = Toolshed::Client.default_pivotal_tracker_project_id
        unless (Toolshed::Client.use_defaults)
          print "Project ID (Default: #{Toolshed::Client.default_pivotal_tracker_project_id})? "
          in_project_id = $stdin.gets.chomp.strip
          unless (in_project_id == '')
            project_id = in_project_id
          end
        end

        pivotal_tracker = Toolshed::TicketTracking::PivotalTracker.new({ project_id: project_id, username: Toolshed::TicketTracking::PivotalTracker.username, password: Toolshed::TicketTracking::PivotalTracker.password })
      end

      def self.clean(title)
        title.gsub("'", "").gsub("\"", "")
      end
    end
  end
end
