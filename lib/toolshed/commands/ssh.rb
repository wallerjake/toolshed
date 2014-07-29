module Toolshed
  module Commands
    class SSH
      def execute(args, options = {})
        puts "running ssh command with options #{options.inspect}" unless options[:verbose_output].blank?
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
