require 'toolshed/cli'
require 'optparse'

module Toolshed
  module Commands
    class Base
      def initialize(options={})
      end

      def self.parse(command, cli_options = {})
        options = {}
        options_parser = OptionParser.new do |opts|
          cli_options.each do |option, option_params|
            opts.on(option_params[:on]) do |opt|
              value = (option_params[:default].nil?) ? opt : option_params[:default]
              options.merge!(option_params[:name] => value)
            end
          end
        end
        options_parser.order! if options_parser
        begin
          cli = Toolshed::CLI.new
          cli.execute(command, ARGV, options)
        rescue Toolshed::CommandNotFound => e
          puts e.message
        end
      end

      def parse(options = {})

      end

      def read_user_input(message, options={})
        return options[:default] if Toolshed::Client.instance.use_defaults
        prompt_user_input(message, options)
      end

      def read_user_input_title(message, options={})
        return options[:title] if options.has_key?(:title)
        read_user_input(message, options)
      end

      def read_user_input_body(message, options={})
        return options[:body] if options.has_key?(:body)
        read_user_input(message, options)
      end

      def use_ticket_tracker_project_id(options)
        options
        options.merge!({
          ticket_tracker_const: 'USE_PROJECT_ID',
          type: :project_id,
          default_method: 'default_pivotal_tracker_project_id',
          default_message: "Project ID (Default: #{Toolshed::Client.instance.default_pivotal_tracker_project_id}):",
        })
        options = use_ticket_tracker_by_type(options)
      end

      def use_ticket_tracker_project_name(options)
        options.merge!({
          ticket_tracker_const: 'USE_PROJECT_NAME',
          type: :project,
          default_method: 'default_ticket_tracker_project',
          default_message: "Project Name (Default: #{Toolshed::Client.instance.default_ticket_tracker_project}):",
        })
        use_ticket_tracker_by_type(options)
      end

      def use_ticket_tracker_by_type(options)
        use_field = Object.const_get("#{ticket_tracker_class}::#{options[:ticket_tracker_const]}") rescue false
        if use_field
          ticket_tracker_response = read_user_input(options[:default_message],
            options.merge!({ default: Toolshed::Client.instance.send(options[:default_method]) })
          )
          options.merge!({ options[:type] => ticket_tracker_response })
        end
        options
      end

      def use_project_id
        Object.const_get("#{ticket_tracker_class}::USE_PROJECT_ID") rescue false
      end

      private

        def prompt_user_input(message, options)
          puts message
          value = $stdin.gets.chomp
          value.empty? ? options[:default] : value
        end
    end
  end
end
