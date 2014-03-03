require "toolshed/version"
require 'httparty'
require 'pivotal-tracker'
require 'harvested'
require 'veto'
require 'launchy'
require 'clipboard'

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
end

require 'toolshed/base'
require 'toolshed/client'
require 'toolshed/git/git'
require 'toolshed/git/github'
require 'toolshed/ticket_tracking/ticket_tracking'
require 'toolshed/ticket_tracking/pivotal_tracker'
require 'toolshed/time_tracking/time_tracking'
require 'toolshed/time_tracking/harvest'
require 'toolshed/error'
