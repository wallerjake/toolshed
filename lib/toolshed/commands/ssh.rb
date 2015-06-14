require 'toolshed/server_administration/ssh'

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
        Toolshed.logger.info "Running ssh command with options #{options.inspect}" unless options[:verbose_output].nil? || options[:verbose_output].empty? # rubocop:disable Metrics/LineLength
        begin
          ssh = Toolshed::ServerAdministration::SSH.new(options)
          ssh.execute
        rescue => e
          Toolshed.logger.fatal e.message
          Toolshed.logger.fatal "Unable to connect to #{options[:host]}"
          Toolshed.die
        end
      end
    end
  end
end
