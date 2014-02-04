module Toolshed
  module Commands
    class GetDailyTimeUpdate
      def execute(args, options = {})
        if (Toolshed::Client.time_tracking_tool == 'harvest')
          harvest = Toolshed::TimeTracking::Harvest.new

          puts "Getting time entries:"
          
          notes = harvest.previous
          notes = "#{notes}\n\n#{harvest.today}"

          puts notes
        else
          puts "Time tracking tool is undefined implementation needed"
          exit
        end
      end
    end
  end
end
