module Toolshed
  module Commands
    class SSH
      def self.cli_options
        {
          banner: 'Usage: ssh [options]',
          options: {
            use_sudo: {
              short_on: '-e'
            },
            host: {
              short_on: '-o'
            },
            connection_string_options: {
              short_on: '-n'
            },
            commands: {
              short_on: '-c'
            },
            password: {
              short_on: '-p'
            },
            prompt_for_password: {
              short_on: '-r'
            },
            user: {
              short_on: '-u'
            },
            keys: {
              short_on: '-k'
            },
            sudo_password: {
              short_on: '-s'
            },
            verbose_output: {
              short_on: '-v'
            }
          }
        }
      end

      def execute(args, options = {})
        puts "running ssh command with options #{options.inspect}" unless options[:verbose_output].blank?
        begin
          ssh = Toolshed::ServerAdministration::SSH.new(options)
          ssh.execute
        rescue => e
          puts e.inspect
          puts "Unable to connect to #{options[:host]}"
        end
      end
    end
  end
end
