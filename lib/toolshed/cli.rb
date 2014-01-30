module Toolshed
  class CommandNotFound < RuntimeError
  end

  class CLI
    def execute(command_name, args, options={})
      Toolshed::Client.load_credentials_if_necessary
      command = commands[command_name]
      puts "Command: #{command}"
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

    def commands
      {
        'create_github_pull_request' => Toolshed::Commands::CreateGithubPullRequest,
      }
    end
  end

end

require 'toolshed/commands/create_github_pull_request'
