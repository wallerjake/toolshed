require 'toolshed/commands/base'
require 'toolshed/server_administration/scp'

module Toolshed
  module Commands
    # Shared code between scp classes
    class SCPBase < Toolshed::Commands::Base
      private

      def scp_options(options = nil) # rubocop:disable AbcSize
        options ||= {}
        options[:remote_host] = read_user_input('Remote Host?', required: true) if options[:remote_host].nil? # rubocop:disable LineLength
        options[:remote_path] = read_user_input('Remote Path?', required: true) if options[:remote_path].nil? # rubocop:disable LineLength
        options[:local_path] = read_user_input('Local Path?', required: true) if options[:local_path].nil? # rubocop:disable LineLength
        options[:username] = read_user_input('Username?', required: true) if options[:username].nil? # rubocop:disable LineLength
        options[:password] = read_user_input_password(options[:password])
        options
      end
    end
  end
end
