require 'toolshed/password'

require 'net/ssh'

module Toolshed
  module ServerAdministration
    # SSH class that can ssh to a host and perform commands
    class SSH
      include Toolshed::Password

      attr_accessor :channel, :commands, :data, :host, :keys, :password, :ssh_options, :sudo_password, :user # rubocop:disable LineLength
      attr_reader :silent

      def initialize(options = nil) # rubocop:disable AbcSize, CyclomaticComplexity, PerceivedComplexity, LineLength
        options ||= {}
        @password = options[:password] || ''
        @sudo_password = options[:sudo_password] || ''
        @keys = options[:keys] || ''
        @host = options[:host] || ''
        @user = options[:user] || ''
        @ssh_options = options[:ssh_options] || {}
        @commands = options[:commands] || ''
        @password = options[:password] || ''
        @data = []
        @silent = options[:silent] || false

        set_ssh_options
      end

      def execute
        Net::SSH.start(host, user, ssh_options) do |ssh|
          ssh.open_channel do |channel|
            self.channel = channel
            request_pty
            run_commands
          end
          ssh.loop
        end
        data
      end

      protected

        def run_commands
          # @TODO fix this so it does not just pass in the commands option
          # Converts to string like command1;command2
          channel.exec(commands) do |_ch, success|
            abort 'Could not execute commands!' unless success

            on_data
            on_extended_data
            on_close
          end
        end

        def request_pty
          channel.request_pty do |_ch, success|
            unless silent
              message = (success) ? 'Successfully obtained pty' : 'Could not obtain pty'
              puts message
            end
          end
        end

        def on_close
          channel.on_close do |_ch|
            puts 'Channel is closing!' unless silent
          end
        end

        def on_extended_data
          channel.on_extended_data do |_ch, _type, data|
            puts "stderr: #{data}" unless silent
          end
        end

        def on_data
          channel.on_data do |_ch, data|
            puts "#{data}" unless silent
            self.data << data
            send_data(data)
          end
        end

        def send_data(data)
          send_password_data if data =~ /password/
          # send_yes_no_data if data =~ /Do you want to continue \[Y\/n\]?/
          send_yes_no_data if data =~ %r{Do you want to continue [Y/n]?}
        end

        def send_password_data
          channel.send_data "#{password_from_config(sudo_password)}\n"
        end

        def send_yes_no_data
          channel.send_data "Y\n"
        end

        def set_ssh_options # rubocop:disable AbcSize
          if keys.nil? || keys.empty?
            final_password = password_from_config(password)
            ssh_options.merge!(password: final_password)
          else
            ssh_options.merge!(keys: [keys]) unless keys.nil? || keys.empty?
          end
        end
    end
  end
end
