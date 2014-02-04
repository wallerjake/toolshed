module Toolshed
  module TimeTracking
    class Harvest
      extend TimeTracking

      MAX_ATTEMPTS = 10

      attr_accessor :harvest_client, :project_id

      def initialize(options={})
        username = Toolshed::Client::time_tracking_username
        password = Toolshed::Client::time_tracking_password
        owner = Toolshed::Client.time_tracking_owner

        unless (options[:username].nil?)
          username = options[:username]
        end

        unless (options[:password].nil?)
           password = options[:password]
        end

        unless (options[:sub_domain].nil?)
           owner = options[:sub_domain]
        end

        self.harvest_client = ::Harvest.client('ackmanndickenson', 'jwaller@ackmanndickenson.com', 'V0AU2gRMLhs1')
        self.project_id = self.get_project_id
      end

      def previous(days_ago=1)
        notes = "Previous:\n\n"

        time_entries = self.harvest_client.time.all((DateTime.now - days_ago), self.project_id)
        if (time_entries.size > 0 || days_ago == Toolshed::TimeTracking::Harvest::MAX_ATTEMPTS)
          time_entries.each do |time_entry|
            notes = "#{notes}#{time_entry.notes}\n"
          end
        else
          notes = self.previous(days_ago + 1)
        end

        notes
      end

      def today
        notes = "Today:\n\n"

        time_entries = self.harvest_client.time.all(Time.now, self.project_id)
        time_entries.each do |time_entry|
          notes = "#{notes}#{time_entry.notes}\n"
        end

        notes
      end

      def get_project_id
        print "Project ID (Default: #{Toolshed::Client.time_tracking_default_project_id})? "
        project_id = $stdin.gets.chomp.strip
        if (project_id == '')
          project_id = Toolshed::Client.time_tracking_default_project_id
        end

        project_id
      end
    end
  end
end
