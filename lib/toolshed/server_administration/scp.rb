require 'toolshed/server_administration/ssh'
require 'toolshed/password'

require 'net/scp'
require 'ruby-progressbar'

module Toolshed
  module ServerAdministration
    # Handles SCP file from one place to another
    class SCP
      include Toolshed::Password

      attr_reader :local_path, :password, :remote_host, :remote_path, :username, :verbose_output # rubocop:disable LineLength

      def initialize(options = nil)
        options ||= {}

        @password = options[:password]
        @remote_host = options[:remote_host]
        @remote_path = options[:remote_path]
        @local_path = options[:local_path]
        @username = options[:username]
        @verbose_output = options[:verbose_output]
      end

      def download
        Toolshed.logger.info "Attempting to SCP from #{username}@#{remote_host}:#{remote_path} to #{local_path}." # rubocop:disable LineLength
        Net::SCP.download!(remote_host, username, remote_path, local_path, ssh: { password: password_from_config(password) }, recursive: true) # rubocop:disable LineLength
        on_complete
      end

      def upload
        Toolshed.logger.info "Attempting to SCP from #{local_path} to #{username}@#{remote_host}:#{remote_path}." # rubocop:disable LineLength
        Net::SCP.upload!(remote_host, username, local_path, remote_path, ssh: { password: password_from_config(password) }, recursive: true) # rubocop:disable LineLength
        on_complete
      end

      private

      def on_complete
        Toolshed.logger.info ''
        Toolshed.logger.info 'SCP file transfer has completed.'
      end
    end
  end
end
