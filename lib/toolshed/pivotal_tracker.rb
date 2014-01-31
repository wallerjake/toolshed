module Toolshed
  class PivotalTracker
    include HTTParty

    STORY_STATUS_DEFAULT = 'finished'

    attr_accessor :project_id, :token

    def initialize(options={})
      self.token = ::PivotalTracker::Client.token(Toolshed::Client.pivotal_tracker_username, Toolshed::Client.pivotal_tracker_password)

      self.project_id = (options[:project_id].nil?) ? Toolshed::Client.default_pivotal_tracker_project_id : options[:project_id]
      @pt_project = ::PivotalTracker::Project.find(self.project_id)
    end

    def self.story_id_from_branch_name(branch_name)
      story_id = branch_name.split("_")[0]
    end

    def story_information(story_id)
      return @pt_project.stories.find(story_id)
    end

    def add_note(story_id, note_text)
      story = @pt_project.stories.find(story_id)
      results = story.notes.create(text: note_text)
    end

    def update_story_state(story_id, current_state, options={})
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
  end
end
