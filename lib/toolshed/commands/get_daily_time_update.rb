module Toolshed
  module Commands
    class GetDailyTimeUpdate
      def self.cli_options
        {
          banner: 'Usage: get_daily_time_update [options]',
          options: {
            format: {
              short_on: '-f',
            },
            use_defaults: {
              short_on: '-d'
            },
            project_id: {
              short_on: '-p',
            }
          }
        }
      end

      def execute(args, options = {})
        begin
          time_tracking_class =  Object.const_get("Toolshed::TimeTracking::#{Toolshed::Client.instance.time_tracking_tool.camel_case}")

          time_tracking_project_id = read_user_input_project_id("Project ID (Default: #{Toolshed::Client.instance.time_tracking_default_project_id}):", options.merge!({ default: Toolshed::Client.instance.time_tracking_default_project_id }))
          options.merge!({ project_id: time_tracking_project_id })
          time_tracker = time_tracking_class.create_instance(options)

          puts "Getting time entries:"
          time_tracker.display
        rescue Exception => e
          puts "Time tracking tool is undefined implementation needed or an error occured #{e.inspect}"
          return
        end
      end

      def read_user_input_project_id(message, options)
        return options[:project_id] if (options.has_key?(:project_id))
        return options[:default] if (Toolshed::Client.instance.use_defaults)

        puts message
        value = $stdin.gets.chomp
        if (value.empty?)
          value = options[:default]
        end

        value
      end
    end
  end
end
