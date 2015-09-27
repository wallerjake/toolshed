require 'toolshed/password'

require 'net/ssh'

module Toolshed
  module ServerAdministration
    class SSH
      attr_accessor :keys, :password, :sudo_password, :host, :user, :ssh_options, :channel, :commands, :password, :data
      attr_reader :silent

      def initialize(options={})
        self.password = options[:password] ||= ''
        self.sudo_password = options[:sudo_password] ||= ''
        self.keys = options[:keys] ||= ''
        self.host = options[:host] ||= ''
        self.user = options[:user] ||= ''
        self.ssh_options = options[:ssh_options] ||= {}
        self.commands = options[:commands] ||= ''
        self.password = Toolshed::Password.new(options)
        self.data = []
        @silent = options[:silent] || false

        set_ssh_options
      end

      def execute
        Net::SSH.start(self.host, self.user, self.ssh_options) do |ssh|
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
          # @TODO fix this so it does not just pass in the commands option but converts to a string i.e. command1;command2
          self.channel.exec(self.commands) do |ch, success|
            abort "Could not execute commands!" unless success

            on_data
            on_extended_data
            on_close
          end
        end

        def request_pty
          self.channel.request_pty do |ch, success|
            puts (success) ? "Successfully obtained pty" : "Could not obtain pty" unless silent
          end
        end

        def on_close
          self.channel.on_close do |ch|
            puts "Channel is closing!" unless silent
          end
        end

        def on_extended_data
          self.channel.on_extended_data do |ch, type, data|
            puts "stderr: #{data}" unless silent
          end
        end

        def on_data
          self.channel.on_data do |ch, data|
            puts "#{data}" unless silent
            self.data << data
            send_data(data)
          end
        end

        def send_data(data)
          send_password_data if data =~ /password/
          send_yes_no_data if data =~ /Do you want to continue \[Y\/n\]?/
        end

        def send_password_data
          self.channel.send_data "#{@password.read_user_input_password('sudo_password')}\n"
        end

        def send_yes_no_data
          self.channel.send_data "Y\n"
        end

        def set_ssh_options
          self.ssh_options.merge!({ keys: [self.keys] }) unless keys.nil? || keys.empty?
          self.ssh_options.merge!({ password: self.password.read_user_input_password('password') }) if keys.nil? || keys.empty?
        end
    end
  end
end
