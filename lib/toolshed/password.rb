require 'toolshed/client'

module Toolshed
  module Password
    def password_from_config(password)
      return '' if password.nil? || password.empty?

      begin
        credentials = Toolshed::Client.read_credenials
        password_parts = password.split(':')
        password_parts.each do |password_part|
          return password if credentials[password_part].nil?
          credentials = credentials[password_part]
        end
      rescue => e
        Toolshed::Logger.instance.fatal e.message
        Toolshed::Logger.instance.fatal e.inspect
        return password
      end
      credentials
    end
  end
end
