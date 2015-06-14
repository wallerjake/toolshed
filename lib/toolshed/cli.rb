require 'toolshed'

module Toolshed
  class CommandNotFound < RuntimeError
  end

  class CLI
    def execute(command_name, args, options={})
      load_config(command_name)
      command = self.send(command_name)
      if command
        begin
          command.new.execute(args, options)
        rescue Toolshed::Error => e
          Toolshed.logger.fatal "An error occurred: #{e.message}"
        rescue RuntimeError => e
          Toolshed.logger.fatal "An error occurred: #{e.message}"
        end
      else
        raise CommandNotFound, "Unknown command: #{command_name}"
      end
    end

    def load_config(command_name)
      begin
        loaded_from_path = Toolshed::Client.load_credentials
        Toolshed.add_file_log_source(command_name)
        Toolshed.logger.info "Credentials loaded from #{File.absolute_path(Toolshed::Client.instance.credentials_loaded_from)}"
      rescue => e
        Toolshed.logger.fatal "Error loading your credentials: #{e.message}"
      end
    end

    def method_missing(method_name, *args, &block)
      begin
        require "toolshed/commands/#{method_name}"
        "Toolshed::Commands::#{translate_method_name(method_name)}".split('::').inject(Object) { |o,c| o.const_get c }
      rescue NameError => e
        Toolshed.logger.fatal e.message
        Toolshed.die
      end
    end

    def translate_method_name(name)
      name = name.to_s
      name.upcase! if %w(ssh).include?(name.downcase)
      name.camel_case
    end
  end
end
