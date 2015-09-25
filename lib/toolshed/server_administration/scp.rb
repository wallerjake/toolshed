require 'net/scp'

module Toolshed
  module ServerAdministration
    class SCP
      attr_reader :local_path, :password, :remote_host, :remote_path, :username, :verbose_output

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
        Toolshed.logger.info "Attempting to SCP from #{username}@#{remote_host}:#{remote_path} to #{local_path}."
        Net::SCP.download!(remote_host, username, remote_path, local_path, ssh: { password: password }, recursive: true) do |ch, name, sent, total|
          # TODO - add progress report here
        end
        Toolshed.logger.info ''
        Toolshed.logger.info 'SCP file transfer has completed.'
      end
    end
  end
end
