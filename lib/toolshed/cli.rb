require 'toolshed'

module Toolshed
  # Command not found
  class CommandNotFound < RuntimeError
  end

  # CLI is responsible for executing the initial command
  class CLI
    def execute(command_name, args, options = {})
      load_config(command_name)
      command = send(command_name)
      if command
        begin
          command.new.execute(args, options)
        rescue Toolshed::Error => e
          Toolshed.logger.fatal "An error occurred: #{e.message}"
        rescue RuntimeError => e
          Toolshed.logger.fatal "An error occurred: #{e.message}"
        end
      else
        fail CommandNotFound, "Unknown command: #{command_name}"
      end
    end

    def load_config(command_name)
      Toolshed::Client.load_credentials
      Toolshed.add_file_log_source(command_name)
      Toolshed.logger.info "Credentials loaded from #{File.absolute_path(Toolshed::Client.instance.credentials_loaded_from)}" # rubocop:disable Metrics/LineLength
    rescue => e
      Toolshed.logger.fatal "Error loading your credentials: #{e.message}"
    end

    def method_missing(method_name)
      require "toolshed/commands/#{method_name}"
      "Toolshed::Commands::#{translate_method_name(method_name)}".split('::').inject(Object) { |o, c| o.const_get c } # rubocop:disable Metrics/LineLength
    rescue NameError => e
      Toolshed.logger.fatal e.message
      Toolshed.die
    end

    def translate_method_name(name)
      name = name.to_s
      name.upcase! if %w(ssh).include?(name.downcase)
      name.camel_case
    end
  end
end
