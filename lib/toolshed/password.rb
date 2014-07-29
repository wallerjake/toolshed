module Toolshed
  class Password
    attr_accessor :password, :sudo_password

    def initialize(options={})
      self.password = options[:password] ||= ''
      self.sudo_password = options[:sudo_password] ||= ''
    end

    def read_user_input_password(type, prompt_message='Password:')
      unless self.send(type).blank?
        read_password_from_configuration(type)
      else
        prompt_user_input_password(prompt_message)
      end
    end

    protected

      def prompt_user_to_input_password(message)
        system "stty -echo"
        puts message
        value = $stdin.gets.chomp.strip
        system "stty echo"

        value
      end

      def read_password_from_configuration(type)
        credentials = Toolshed::Client.read_credenials
        if credentials[self.send(type)]
          credentials[self.send(type)]
        else
          self.send(type)
        end
      end
  end
end
