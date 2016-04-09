require 'open3'
require 'timeout'

module Toolshed
  # Base class for toolshed responsible for methods used all over.
  class Base
    def initialize
    end

    def self.wait_for_command(command, seconds = 10) # rubocop:disable Metrics/AbcSize, Metrics/MethodLength, Metrics/LineLength
      result = {}
      Open3.popen3(command) do |stdin, stdout, stderr, wait_thr|
        begin
          ::Timeout.timeout(seconds) do
            stdin.close  # make sure the subprocess is done

            a_stdout = []
            while line = stdout.gets
              a_stdout << line
            end
            a_stderr = []
            while line = stderr.gets
              a_stderr << line
            end

            all = a_stdout + a_stderr
            exit_status = wait_thr.value.to_s # Process::Status object returned.
            result.merge!(stdout: a_stdout, stderr: a_stderr, all: all, process_status: exit_status) # rubocop:disable Metrics/LineLength
          end
        rescue ::Timeout::Error
          Process.kill('KILL', wait_thr.pid)
          Toolshed.logger.fatal "Unable to perform the '#{command}' command in the allowed amount of time of #{seconds} seconds. Exiting." # rubocop:disable Metrics/LineLength
          Toolshed.die
        end
      end
      result
    end
  end
end

String.class_eval do
  def camel_case
    return self if self !~ /_/ && self =~ /[A-Z]+.*/
    split('_').map(&:capitalize).join
  end
end
