require 'toolshed'
require 'toolshed/client'

module Toolshed
  # Password module looks up password from configuration file if its found
  module Password
    def password_from_config(password)
      return '' if password.nil? || password.empty?

      translated_password = Toolshed.configuration
      return password unless translated_password.is_a?(Hash)

      password_parts = password.split(':')
      password_parts.each do |password_part|
        if translated_password[password_part].nil?
          translated_password = password
          break
        end
        translated_password = translated_password[password_part]
      end
      translated_password
    rescue => e
      Toolshed::Logger.instance.fatal e.message
      Toolshed::Logger.instance.fatal e.inspect
      password
    end
  end
end
