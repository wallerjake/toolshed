require 'toolshed'

module Toolshed
  # Command not found
  class CommandNotFound < RuntimeError
  end

  # CLI is responsible for executing the initial command
  class CLI
    def execute(command_class, args, options = {})
      load_config(command_class)
      begin
        command_class.new.execute(args, options)
      rescue Toolshed::Error => e
        Toolshed.logger.fatal "An error occurred: #{e.message}"
      rescue RuntimeError => e
        Toolshed.logger.fatal "An error occurred: #{e.message}"
      end
    end

    def load_config(command_class)
      Toolshed::Client.load_credentials
      Toolshed.add_file_log_source(command_class.class.name)
      Toolshed.logger.info "Credentials loaded from #{File.absolute_path(Toolshed::Client.instance.credentials_loaded_from)}" # rubocop:disable Metrics/LineLength
    rescue => e
      Toolshed.logger.fatal "Error loading your credentials: #{e.message}"
    end
  end
end
