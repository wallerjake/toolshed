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
          opts.banner = cli_options[:banner] if cli_options[:banner]
          cli_options[:options].each do |option_name, option_variables|
            letter_map = ('a'..'z').map { |letter| letter }
            short_on = (option_variables[:short_on]) ? option_variables[:short_on] : letter_map[rand(letter_map.length)]
            on = (option_variables[:on]) ? option_variables[:on] : "--#{option_name.to_s.split('_').join('-')} [ARG]"
            opts.on(short_on, on) do |opt|
              value = (option_variables[:default].nil?) ? opt : option_variables[:default]
              options.merge!(option_name => value)
            end
          end
        end
        options_parser.order! if options_parser
        begin
          cli = Toolshed::CLI.new
          cli.execute(command, ARGV, options)
        rescue Toolshed::CommandNotFound => e
          Toolshed.logger.fatal e.message
          Toolshed.die
        end
      end

      def read_user_input(message, options = {})
        return options[:default] if Toolshed::Client.instance.use_defaults
        required = options[:required] || false
        value = ''
        if required
          until !value.empty?
            value = prompt_user_input(message, options)
          end
        else
          value = prompt_user_input(message, options)
        end
        value
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
          required = options[:required] || false
          puts message
          value = $stdin.gets.chomp
          if required && value.nil? || value.empty?
            puts 'Value is required please try again.'
            return value
          end
          (value.nil? || value.empty?) ? options[:default] : value
        end
    end
  end
end
