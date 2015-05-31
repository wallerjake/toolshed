require 'open3'
require 'timeout'

module Toolshed
  class Base
    def initialize
    end

    def self.wait_for_command(command, seconds=10)
      result = {}
      Open3.popen3(command) do |stdin, stdout, stderr, wait_thr|
        begin
          Timeout.timeout(seconds) do
            stdin.close  # make sure the subprocess is done
            stderr.gets
            stdout.gets

            a_stdout = []
            stdout.each_line do |line|
              a_stdout << line
            end

            a_stderr = []
            stderr.each_line do |line|
              a_stderr << line
            end

            all = a_stdout + a_stderr
            exit_status = wait_thr.value # Process::Status object returned.
            result.merge!(stdout: a_stdout, stderr: a_stderr, all: all, process_status: exit_status)
          end
        rescue Timeout::Error
          Process.kill("KILL", wait_thr.pid)
          Toolshed.logger.fatal "Unable to perform the '#{command}' command in the allowed amount of time of #{seconds} seconds. Exiting."
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
    split('_').map{|e| e.capitalize}.join
  end
end
