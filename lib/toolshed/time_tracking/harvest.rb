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

        self.harvest_client = ::Harvest.client(subdomain: owner, username: username, password: password)
        self.project_id = options[:project_id] unless !options.has_key?(:project_id)

        # setup formatting
        formatter(options)
      end

      def previous_time_entries(days_ago, options={})
        entries = self.harvest_client.time.all((DateTime.now - days_ago), self.project_id)

        if (entries.size > 0 || days_ago == Toolshed::TimeTracking::Harvest::MAX_ATTEMPTS)
          entries
        else
          entries = self.previous_time_entries(days_ago + 1)
        end
      end

      def previous_notes(days_ago=1, options={})
        notes = "Previous:#{self.line_break}"

        time_entries = previous_time_entries(days_ago, options)

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

      def todays_time_entries
        self.harvest_client.time.all(Time.now, self.project_id)
      end

      def todays_notes
        notes = "Today:#{self.line_break}"
        notes = "#{notes}#{self.start_unorder_list}"
        self.todays_time_entries.each do |time_entry|
          notes = "#{notes}#{self.start_list_item}#{time_entry.notes}#{self.end_list_item}"
          if (self.end_list_item == '')
            notes = "#{notes}#{self.line_break}"
          end
        end
        notes = "#{notes}#{self.end_unorder_list}"

        notes
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

      def display
        notes = self.previous_notes
        notes = "#{notes}#{self.line_break}#{self.line_break}#{self.todays_notes}"
        notes = "#{notes}#{self.brought_to_you_by_message}"

        if (self.format == 'html')
          FileUtils.rm_rf(Toolshed::TimeTracking::Harvest::GENERATED_HTML_FILE_LOCATION)
          File.open(Toolshed::TimeTracking::Harvest::GENERATED_HTML_FILE_LOCATION, 'w') {|f| f.write(notes) }
          Launchy.open( Toolshed::TimeTracking::Harvest::GENERATED_HTML_FILE_LOCATION ) do |exception|
            puts "Attempted to open #{uri} and failed because #{exception}"
          end
          puts "Checkout out your default or open browser!"
        else
          puts notes
        end

        return
      end

      def self.create_instance(options={})
        Toolshed::TimeTracking::Harvest.new(options)
      end
    end
  end
end
