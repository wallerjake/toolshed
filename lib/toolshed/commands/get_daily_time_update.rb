module Toolshed
  module Commands
    class GetDailyTimeUpdate
      def execute(args, options = {})
        if (Toolshed::Client.time_tracking_tool == 'harvest')
          harvest = Toolshed::TimeTracking::Harvest.new(options)

          puts "Getting time entries:"
          
          notes = harvest.previous
          notes = "#{notes}#{harvest.line_break}#{harvest.line_break}#{harvest.today}"
          notes = "#{notes}#{harvest.brought_to_you_by_message}"

          if (harvest.format == 'html')
            FileUtils.rm_rf(Toolshed::TimeTracking::Harvest::GENERATED_HTML_FILE_LOCATION)
            File.open(Toolshed::TimeTracking::Harvest::GENERATED_HTML_FILE_LOCATION, 'w') {|f| f.write(notes) }
            Launchy.open( Toolshed::TimeTracking::Harvest::GENERATED_HTML_FILE_LOCATION ) do |exception|
              puts "Attempted to open #{uri} and failed because #{exception}"
            end
            puts "Checkout out your default or open browser!"
          else
            puts notes
          end
        else
          puts "Time tracking tool is undefined implementation needed"
          exit
        end
      end
    end
  end
end
