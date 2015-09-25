require 'toolshed/commands/base'
require 'toolshed/password'
require 'toolshed/server_administration/scp'

module Toolshed
  module Commands
    module SCP
      class Download < Toolshed::Commands::Base
        def self.cli_options
          {
            banner: 'Usage: scp download [options]',
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

        def execute(args, options = nil)
          options ||= nil
          Toolshed.logger.info ''
          Toolshed::ServerAdministration::SCP.new(scp_options(options)).download
          Toolshed.die
        end

        private

        def scp_options(options = nil)
          options ||= {}
          options[:remote_host] = read_user_input('Remote Host?', required: true) if options[:remote_host].nil?
          options[:remote_path] = read_user_input('Remote Path?', required: true) if options[:remote_path].nil?
          options[:local_path] = read_user_input('Local Path?', required: true) if options[:local_path].nil?
          options[:username] = read_user_input('Username?', required: true) if options[:username].nil?

          password = Toolshed::Password.new(options).read_user_input_password('password')
          options.merge!(password: password)
          options
        end
      end
    end
  end
end
