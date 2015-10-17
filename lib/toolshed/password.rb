require 'toolshed'
require 'toolshed/client'

module Toolshed
  # Password module looks up password from configuration file if its found
  module Password
    def password_from_config(password)
      return '' if password.nil? || password.empty?

      translated_password = Toolshed.configuration
      password_parts = password.split(':')
      password_parts.each do |password_part|
        return password if translated_password[password_part].nil?
        translated_password = translated_password[password_part]
      end
      return translated_password
    rescue => e
      Toolshed::Logger.instance.fatal e.message
      Toolshed::Logger.instance.fatal e.inspect
      return password
    end
  end
end
