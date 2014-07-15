require 'net/ssh'

module Toolshed
  module Commands
    class SSH
      def execute(args, options = {})
        puts "running ssh command with options #{options.inspect}"
        @ssh_options = {}

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
                  channel.send_data "#{read_user_input_password('Password:')}\n" if data =~ /password/
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

      def read_user_input_password(message)
        system "stty -echo"
        puts message
        value = $stdin.gets.chomp.strip
        system "stty echo"

        value
      end

      def add_in_ssh_options(options={})
        @ssh_options.merge!({ keys: [options[:keys]] }) unless options[:keys].nil?
        @ssh_options.merge!({ password: read_user_input_password('Password:') }) if options[:keys].nil?
      end
    end
  end
end
