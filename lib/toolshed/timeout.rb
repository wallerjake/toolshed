require 'time'

module Toolshed
  # Raised by Timeout#timeout when the block times out.
  class TimeoutError < RuntimeError
    attr_reader :thread

    def self.catch(*args)
      exc = new(*args)
      exc.instance_variable_set(:@thread, Thread.current)
      ::Kernel.catch(exc) {yield exc}
    end

    def exception(*)
      # TODO: use Fiber.current to see if self can be thrown
      if self.thread == Thread.current
        bt = caller
        begin
          throw(self, bt)
        rescue UncaughtThrowError
        end
      end
      self
    end
  end

  THIS_FILE = /\A#{Regexp.quote(__FILE__)}:/o
  CALLER_OFFSET = ((c = caller[0]) && THIS_FILE =~ c) ? 1 : 0
  private_constant :THIS_FILE, :CALLER_OFFSET

  # https://github.com/ruby/ruby/blob/trunk/lib/timeout.rb
  # This code had to be modified so the timeout could be extended instead of just being a fixnum.
  # This is import for the SSH client as we want it to keep running for an unlimited time period as
  # long as we are getting output from the client. When that stops then the timeout needs to kick in
  # just in case the server is no longer responding or a connection got lost. Too bad ruby core doesn't
  # already support something like this.
  class Timeout
    attr_accessor :start_time
    attr_reader :timeout_period

    def initialize(options = nil)
      options ||= {}
      @timeout_period = options[:timeout_period] || 30
      @start_time = options[:start_time] || Time.now.utc.to_i
    end

    def reset_start_time
      @start_time = Time.now.utc.to_i
    end

    def timeout(klass = nil)   #:yield: +sec+
      return yield(timeout_period) if timeout_period == nil or timeout_period.zero?
      message = "execution expired in #{timeout_period} seconds".freeze
      e = TimeoutError
      bl = proc do |exception|
        begin
          x = Thread.current
          y = Thread.start {
            begin
              sleep(1) until timed_out?
            rescue => e
              x.raise e
            else
              x.raise exception, message
            end
          }
          return yield(timeout_period)
        ensure
          if y
            y.kill
            y.join # make sure y is dead.
          end
        end
      end
      if klass
        begin
          bl.call(klass)
        rescue klass => e
          bt = e.backtrace
        end
      else
        bt = TimeoutError.catch(message, &bl)
      end
      level = -caller(CALLER_OFFSET).size-2
      while THIS_FILE =~ bt[level]
        bt.delete_at(level)
      end
      raise(e, message, bt)
    end

    def timed_out?
      Time.now.utc.to_i - start_time > timeout_period
    end
  end
end
