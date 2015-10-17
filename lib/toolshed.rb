require 'toolshed/base'
require 'toolshed/client'
require 'toolshed/error'
require 'toolshed/logger'
require 'toolshed/version'

require 'httparty'
require 'launchy'
require 'clipboard'
require 'fileutils'

# Helper methods for toolshed
module Toolshed
  BLANK_REGEX = /\S+/

  class << self
    def add_file_log_source(command_name = '')
      log_path = Toolshed.configuration.log_path
      return if log_path.nil? || log_path.empty?

      FileUtils.mkdir_p(log_path)
      command_name_string = '_'
      command_name_string = "_#{command_name}_" unless command_name.nil? || command_name.empty? # rubocop:disable Metrics/LineLength
      file_name = "toolshed#{command_name_string}#{Time.now.utc.strftime('%Y%m%d%H%M%S%L')}" # rubocop:disable Metrics/LineLength
      file = "#{log_path}/#{file_name}"
      FileUtils.touch(file)
      logger.add_log_source(file)
    end

    def configuration
      Toolshed::Client.instance
    end

    def deprecate(message = nil)
      message ||= 'You are using deprecated behavior which will be removed from the next major or minor release.' # rubocop:disable Metrics/LineLength
      warn("DEPRECATION WARNING: #{message}")
    end

    def die(message = '', exit_code = -1)
      logger.fatal message unless message.nil? || message.empty?
      Kernel.exit(exit_code)
    end

    def logger
      @logger ||= begin
        Toolshed::Logger.create(log_sources: [STDOUT])
        Toolshed::Logger.instance
      end
    end
  end
end
