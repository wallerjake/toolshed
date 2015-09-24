module Toolshed
  module Commands
    module SCP
      class Download
        def self.cli_options
          {
            banner: 'Usage: scp download [options]',
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
          puts 'running scp download!'
          Toolshed.die
        end
      end
    end
  end
end
