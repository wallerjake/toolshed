module Toolshed
  class Base
    def initialize
    end

    def self.wait_for_command(command, seconds=10)
      result = {}
      Open3.popen3(command) do |stdin, stdout, stderr, wait_thr|
        pid = wait_thr.pid # pid of the started process.
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

        result.merge!(stdout: a_stdout, stderr: a_stderr)
        exit_status = wait_thr.value # Process::Status object returned.
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
