require "toolshed/version"
require 'httparty'
require 'pivotal-tracker'
require 'jira'
require 'harvested'
require 'veto'
require 'launchy'
require 'clipboard'
require 'toolshed/logger'
require 'fileutils'

module Toolshed
  BLANK_REGEX = /\S+/

  # Echoes a deprecation warning message.
  #
  # @param  [String] message The message to display.
  # @return [void]
  #
  # @api internal
  # @private
  def self.deprecate(message = nil)
    message ||= "You are using deprecated behavior which will be removed from the next major or minor release."
    warn("DEPRECATION WARNING: #{message}")
  end

  def self.logger
    @logger ||= begin
      Toolshed::Logger.create(log_sources: [STDOUT])
      Toolshed::Logger.instance
    end
  end

  def self.add_file_log_source(command_name = '')
    log_path = Toolshed::Client.instance.log_path
    unless log_path.blank?
      FileUtils.mkdir_p(log_path)
      command_name_string = '_'
      command_name_string = "_#{command_name}_" unless command_name.blank?
      file_name = "toolshed#{command_name_string}#{Time.now.utc.strftime('%Y%m%d%H%M%S%L')}"
      file = "#{log_path}/#{file_name}"
      FileUtils.touch(file)
      self.logger.add_log_source(file)
    end
  end

  def self.die(message = '', exit_code = -1)
    logger.fatal message unless message.blank?
    Kernel.exit(exit_code)
  end
end

require 'toolshed/base'
require 'toolshed/client'
require 'toolshed/ticket_tracking/ticket_tracking'
require 'toolshed/ticket_tracking/pivotal_tracker'
require 'toolshed/ticket_tracking/jira'
require 'toolshed/time_tracking/time_tracking'
require 'toolshed/time_tracking/harvest'
require 'toolshed/error'
require 'toolshed/password'
require 'toolshed/server_administration/ssh'
