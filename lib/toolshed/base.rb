module Toolshed
  class Base
    def initialize
      puts "#{__FILE__} #{__LINE__}"
    end

    def self.wait_for_command(command, seconds=10)
      begin
        Timeout::timeout(seconds) {
          until (system(command))
            sleep 1
          end
          return true
        }
      rescue Timeout::Error => e
        puts "Unable to execute command after #{seconds} seconds"
        return
      end
    end
  end
end

String.class_eval do
  def camel_case
    return self if self !~ /_/ && self =~ /[A-Z]+.*/
    split('_').map{|e| e.capitalize}.join
  end
end
