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
      log_sources = [STDOUT]
      log_path = Toolshed::Client.instance.log_path
      unless log_path.blank?
        FileUtils.mkdir_p(log_path)
        file = "#{log_path}/toolshed_#{Time.now.utc.strftime('%Y%m%d%H%M%S%L')}"
        FileUtils.touch(file)
        log_sources << file
      end

      Toolshed::Logger.create(log_sources: log_sources)
      Toolshed::Logger.instance
    end
  end

  def self.die(message = '', exit_code = -1)
    logger.fatal message unless message.blank?
    Kernel.exit(exit_code)
  end
end

require 'toolshed/base'
require 'toolshed/client'
require 'toolshed/git/git'
require 'toolshed/git/github'
require 'toolshed/ticket_tracking/ticket_tracking'
require 'toolshed/ticket_tracking/pivotal_tracker'
require 'toolshed/ticket_tracking/jira'
require 'toolshed/time_tracking/time_tracking'
require 'toolshed/time_tracking/harvest'
require 'toolshed/error'
require 'toolshed/password'
require 'toolshed/server_administration/ssh'
