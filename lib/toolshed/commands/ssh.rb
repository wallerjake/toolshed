module Toolshed
  module Commands
    class SSH
      def execute(args, options = {})
        puts "running ssh command with options #{options.inspect}"
        begin
          ssh = Toolshed::ServerAdministration::SSH.new(options)
          ssh.execute
        rescue => e
          puts e.inspect
          puts "Unable to connect to #{options[:host]}"
        end
      end
    end
  end
end
