require 'toolshed/commands/base'
require 'toolshed/databases/mysql/backup'

module Toolshed
  module Commands
    module Mysql
      # Responsible for handing backup of mysql database
      class Backup < Toolshed::Commands::Base
        def self.cli_options # rubocop:disable MethodLength
          {
            banner: 'Usage: mysql backup [options]',
            options: {
              local_host: {
                short_on: '-l'
              },
              path: {
                short_on: '-p'
              },
              username: {
                short_on: '-u'
              },
              password: {
                short_on: '-d'
              },
              name: {
                short_on: '-n'
              },
              wait_time: {
                short_on: '-w'
              }
            }
          }
        end

        def execute(_args, options = nil)
          options = options_with_defaults(options)
          Toolshed.logger.info ''
          Toolshed::Databases::Mysql::Backup.new(options).execute
          Toolshed.logger.info ''
          Toolshed.die
        end

        private

        def options_with_defaults(options = nil)
          options ||= {}
          options[:local_host] ||= 'localhost'
          options[:path] ||= read_user_input("Storage Path (/tmp/test/#{Time.now.utc.getlocal.strftime('%Y%m%d')}.sql) ?", required: true)
          options[:username] ||= read_user_input('Username?', required: true)
          options[:name] ||= read_user_input('Database Name?', required: true)
          options
        end
      end
    end
  end
end
