require 'toolshed/error'
require 'toolshed/password'

require 'fileutils'

module Toolshed
  module Databases
    module Mysql
      class Backup
        include Toolshed::Password

        attr_reader :host, :name, :path, :password, :username, :wait_time

        def initialize(options = nil)
          options ||= {}
          @host = options[:host]
          @name = options[:name]
          @path = options[:path]
          @password = options[:password]
          @username = options[:username]
          @wait_time = options[:wait_time] || 120
        end

        def create_path
          FileUtils.mkdir_p(File.dirname(path))
        end

        def execute
          raise TypeError, "Wait time passed in is not a number #{wait_time}" unless wait_time.is_a?(Fixnum)
          Toolshed.logger.info "Starting execution of mysqldump -h #{host} -u #{username} #{hidden_password_param} #{name} > #{path}."
          create_path
          results = Toolshed::Base.wait_for_command("mysqldump -h #{host} -u #{username} #{password_param} #{name} > #{path}", wait_time)
          unless results[:stderr].is_a?(NilClass) || results[:stderr].empty?
            error_message = results[:stderr].join(' ')
            Toolshed.logger.fatal error_message
            raise Toolshed::PermissionsException, error_message
          end
          Toolshed.logger.info results[:stdout].join(' ') unless results[:stdout].is_a?(NilClass)
          Toolshed.logger.info 'mysqldump has completed.'
        end

        def password_param
          password.nil? || password.empty?  ? '' : "-p#{password_from_config(password)}"
        end

        def hidden_password_param
          password_param.empty? ? '' : '-p *******'
        end
      end
    end
  end
end
