require 'toolshed/error'
require 'toolshed/hash'
require 'toolshed/version'

require 'erb'
require 'singleton'
require 'yaml'

module Toolshed
  # This is responsible for loading .toolshedrc file
  class Client < Hash
    include Singleton

    GITHUB_BASE_API_URL  = 'https://api.github.com/'
    PIVOTAL_TRACKER_BASE_API_URL = 'https://www.pivotaltracker.com/services/v5/'

    attr_reader :struct

    def initialize
      load_toolshedrc_configuration
      @struct = to_ostruct
    end

    def load_toolshedrc_configuration
      toolshedrc_configurations = YAML.load(ERB.new(File.read(toolshedrc_path)).result)
      raise CorruptFileException, 'Toolshedrc file is not configured properly.' unless toolshedrc_configurations.is_a?(Hash)
      self.merge!(toolshedrc_configurations)
    end

    def method_missing(*args)
      begin
        if args.first.to_s.end_with?('=')
          val = args.last
          my_h = self
          args.each_with_index do |arg, index|
            arg = arg.to_s.gsub('=', '')
            next_arg_val = args[index + 1].to_s.gsub('=', '')
            my_h = my_h[arg] unless next_arg_val == val.to_s
            my_h[arg] = val if next_arg_val == val.to_s && !my_h[arg].nil?
            my_h.merge!(arg => val) if next_arg_val == val.to_s && my_h[arg].nil?
          end
          @struct = to_ostruct
        else
          struct.send(args.first)
        end
      rescue NoMethodError => e
        Toolshed.die(e.message)
      end
    end

   def toolshedrc_path
      @toolshedrc_path ||= begin
        dir = Dir.pwd
        while File.expand_path(dir) != '/'
          unless File.exist?("#{dir}/.toolshedrc")
            dir = File.join dir, '..'
            next
          end
          credentials_loaded_from = "#{dir}/.toolshedrc"
          break
        end
        credentials_loaded_from
      end
    end
  end
end
