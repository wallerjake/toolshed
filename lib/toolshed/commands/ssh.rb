module Toolshed
  module Commands
    class SSH
      def self.cli_options
        {
          banner: 'Usage: ssh [options]',
          options: {
            use_sudo: {
              short_on: '-s'
            },
            host: {
              short_on: '-o'
            },
            connection_string_options: {
              short_on: '-o'
            },
            commands: {
              short_on: '-conn'
            },
            password: {
              short_on: '-p'
            },
            prompt_for_password: {
              short_on: '-pfp'
            },
            user: {
              short_on: '-u'
            },
            keys: {
              short_on: '-k'
            },
            sudo_password: {
              short_on: '-sp'
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
