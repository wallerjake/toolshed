module Toolshed
  module TimeTracking
    class Harvest
      extend TimeTracking

      MAX_ATTEMPTS = 10
      GENERATED_HTML_FILE_LOCATION = '/tmp/toolshed_generated_time_sheet.html'

      attr_accessor :harvest_client, :project_id, :line_break, :start_list_item, :end_list_item, :start_unorder_list, :end_unorder_list, :format

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

        # setup formatting
        formatter(options)
      end

      def previous(days_ago=1, options={})

        notes = "Previous:#{self.line_break}"

        time_entries = self.harvest_client.time.all((DateTime.now - days_ago), self.project_id)
        if (time_entries.size > 0 || days_ago == Toolshed::TimeTracking::Harvest::MAX_ATTEMPTS)
          notes = "#{notes}#{self.start_unorder_list}"
          time_entries.each do |time_entry|
            notes = "#{notes}#{self.start_list_item}#{time_entry.notes}#{self.end_list_item}"
            if (self.end_list_item == '')
              notes = "#{notes}#{self.line_break}"
            end
          end
          notes = "#{notes}#{self.end_unorder_list}"
        else
          notes = self.previous(days_ago + 1)
        end

        notes
      end

      def today
        notes = "Today:#{self.line_break}"

        time_entries = self.harvest_client.time.all(Time.now, self.project_id)
        notes = "#{notes}#{self.start_unorder_list}"
        time_entries.each do |time_entry|
          notes = "#{notes}#{self.start_list_item}#{time_entry.notes}#{self.end_list_item}"
          if (self.end_list_item == '')
            notes = "#{notes}#{self.line_break}"
          end
        end
        notes = "#{notes}#{self.end_unorder_list}"

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

      def brought_to_you_by_message
        "#{self.line_break}Provided by Toolshed https://rubygems.org/gems/toolshed#{self.line_break}"
      end

      def formatter(options={})
        if (options[:format] && options[:format] == 'html')
          self.format = 'html'
          self.line_break = "<br>"
          self.start_list_item = "<li>"
          self.end_list_item = "</li>"
          self.start_unorder_list = "<ul>"
          self.end_unorder_list = "</ul>"
        else
          self.format = 'text'
          self.line_break = "\n"
          self.start_list_item = ""
          self.end_list_item = ""
          self.start_unorder_list = ""
          self.end_unorder_list = ""
        end
      end
    end
  end
end
