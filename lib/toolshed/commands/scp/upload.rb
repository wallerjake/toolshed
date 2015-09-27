require 'toolshed/commands/scp_base'

module Toolshed
  module Commands
    module SCP
      # Responsible for handing uploading of files
      class Upload < Toolshed::Commands::SCPBase
        def self.cli_options # rubocop:disable MethodLength
          {
            banner: 'Usage: scp upload [options]',
            options: {
              remote_host: {
                short_on: '-r'
              },
              remote_path: {
                short_on: '-d'
              },
              local_path: {
                short_on: '-s'
              },
              username: {
                short_on: '-u'
              },
              password: {
                short_on: '-p'
              },
              verbose_output: {
                short_on: '-v'
              }
            }
          }
        end

        def execute(_args, options = nil)
          options ||= nil
          Toolshed.logger.info ''
          Toolshed::ServerAdministration::SCP.new(scp_options(options)).upload
          Toolshed.die
        end
      end
    end
  end
end
