require 'net/ssh'

module Toolshed
  module Commands
    class SSH
      def execute(args, options = {})
        puts "running ssh command with options #{options.inspect}"
        @ssh_options = {}
        @password = Toolshed::Password.new(options)

        begin
          add_in_ssh_options(options)

          Net::SSH.start(options[:host], options[:user], @ssh_options) do |ssh|
            ssh.open_channel do |channel|
              channel.request_pty do |ch, success|
                if success
                  puts "Successfully obtained pty"
                else
                  puts "Could not obtain pty"
                end
              end

              # @TODO fix this so it does not just pass in the commands option but converts to a string i.e. command1;command2
              channel.exec(options[:commands]) do |ch, success|
                abort "Could not execute commands!" unless success

                channel.on_data do |ch, data|
                  puts "#{data}"
                  send_data(channel, data, options)
                end

                channel.on_extended_data do |ch, type, data|
                  puts "stderr: #{data}"
                end

                channel.on_close do |ch|
                  puts "Channel is closing!"
                end
              end
            end
            ssh.loop
          end
        rescue => e
          puts e.inspect
          puts "Unable to connect to #{options[:host]}"
        end
      end

      def add_in_ssh_options(options={})
        @ssh_options.merge!({ keys: [options[:keys]] }) unless options[:keys].nil?
        @ssh_options.merge!({ password: @password.read_user_input_password('password') }) if options[:keys].nil?
      end

      def send_data(channel, data, options={})
        if data =~ /password/
          send_password_data(channel, options)
        elsif data =~ /Do you want to continue \[Y\/n\]?/
          send_yes_no_data(channel)
        end
      end

      def send_password_data(channel, options={})
        channel.send_data "#{@password.read_user_input_password('sudo_password')}\n"
      end

      def send_yes_no_data(channel)
        channel.send_data "Y\n"
      end
    end
  end
end
