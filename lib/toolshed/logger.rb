require 'singleton'
require 'term/ansicolor'

class Toolshed::Logger
  include Singleton
  include Term::ANSIColor

  attr_accessor :loggers

  def self.create(options = {})
    instance.loggers = []
    log_sources = options[:log_sources] || [STDOUT]
    log_sources.each do |log_source|
      instance.loggers << Logger.new(log_source)
    end
  end

  def add_log_source(source)
    loggers << Logger.new(source)
  end

  def debug(message)
    loggers.each do |logger|
      logger.debug(message)
    end
  end

  def fatal(message)
    loggers.each do |logger|
      logger.info(red(message))
    end
  end

  def info(message)
    loggers.each do |logger|
      logger.info(green(message))
    end
  end

  def warn(message)
    loggers.each do |logger|
      logger.warn(yellow(message))
    end
  end
end
