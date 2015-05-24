require 'toolshed'

module Toolshed
  class CommandNotFound < RuntimeError
  end

  class CLI
    def execute(command_name, args, options={})
      Toolshed::Client.load_credentials
      command = self.send(command_name)
      if command
        begin
          command.new.execute(args, options)
        rescue Toolshed::Error => e
          puts "An error occurred: #{e.message}"
        rescue RuntimeError => e
          puts "An error occurred: #{e.message}"
        end
      else
        raise CommandNotFound, "Unknown command: #{command_name}"
      end
    end

    def method_missing(method_name, *args, &block)
      require "toolshed/commands/#{method_name}"
      "Toolshed::Commands::#{method_name.to_s.camel_case}".split('::').inject(Object) { |o,c| o.const_get c }
    end
  end
end
