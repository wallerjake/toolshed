require 'toolshed/error'
require 'toolshed/password'

module Toolshed
  module Databases
    module Mysql
      class Backup
        include Toolshed::Password

        attr_reader :local_host, :name, :path, :password, :username, :wait_time

        def initialize(options = nil)
          options ||= {}
          @local_host = options[:local_host]
          @name = options[:name]
          @path = options[:path]
          @password = options[:password]
          @username = options[:username]
          @wait_time = options[:wait_time] || 120
        end

        def execute
          raise TypeError, "Wait time passed in is not a number #{wait_time}" unless wait_time.is_a?(Fixnum)
          Toolshed.logger.info "Starting execution of mysqldump -h #{local_host} -u #{username} -p #{password} #{name} > #{path}."
          Toolshed::Base.wait_for_command("mysqldump -h #{local_host} -u #{username} #{password_param} #{name} > #{path}", wait_time)
          Toolshed.logger.info 'mysqldump has completed.'
        end

        def password_param
          password.nil? || password.empty?  ? '' : "-p #{password}"
        end
      end
    end
  end
end
