#require 'toolshed/commands/base'

module Toolshed
  module Commands
    module Mysql
      # Responsible for handing backup of mysql database
      class Backup #< Toolshed::Commands::Base
        def self.cli_options # rubocop:disable MethodLength
          {
            banner: 'Usage: mysql backup [options]',
            options: {
              local_host: {
                short_on: '-l'
              },
              storage_path: {
                short_on: '-s'
              },
              username: {
                short_on: '-u'
              },
              password: {
                short_on: '-p'
              },
              name: {
                short_on: '-n'
              },
              filename: {
                short_on: '-f'
              }
            }
          }
        end

        def execute(_args, options = nil)
          options ||= nil
          Toolshed.logger.info ''
          Toolshed.logger.info 'executing mysql backup!'
          # Toolshed::ServerAdministration::SCP.new(scp_options(options)).download
          Toolshed.die
        end

        private

        def options_with_defaults(options = nil)
          options ||= {}
        end
      end
    end
  end
end
