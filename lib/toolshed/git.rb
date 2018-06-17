require 'toolshed/base'
require 'toolshed/git/validator'
require 'highline/import'

module Toolshed
  class Git
    require 'toolshed/git/branch'

    DEFAULT_GIT_TOOL    = 'github'
    DEFAULT_BRANCH_FROM = 'master'

    attr_accessor :from_remote_name, :from_remote_branch_name, :to_remote_name, :to_remote_branch_name, :validator, :passed_branch_name, :force

    def initialize(options = {})
      # options with defaults
      self.from_remote_name = Toolshed::Client.instance.pull_from_remote_name
      unless (options[:from_remote_name].nil?)
        self.from_remote_name  = options[:from_remote_name]
      end

      self.to_remote_name = Toolshed::Client.instance.push_to_remote_name
      unless (options[:to_remote_name].nil?)
        self.to_remote_name = options[:to_remote_name]
      end

      # options that do not have a default
      unless (options[:from_remote_branch_name].nil?)
        self.from_remote_branch_name = options[:from_remote_branch_name]
      end

      unless (options[:to_remote_branch_name].nil?)
        self.to_remote_branch_name = options[:to_remote_branch_name]
      end

      self.validator = ::Toolshed::Git::Validator.new
      self.passed_branch_name = options[:branch_name] || ''
      self.force = (options.key?(:force_command)) ? '--force' : ''
    end

    class << self
      def git_submodule_command
        git_submodule_command = ''
        git_submodule_command = "git submodule update #{Toolshed::Client.instance.git_quiet}" if Toolshed::Client.instance.use_git_submodules
        git_submodule_command
      end
    end

    def remote_update
      results = Toolshed::Base.wait_for_command("git remote update #{Toolshed::Client.instance.git_quiet}")
      results[:all].each do |out|
        Toolshed.logger.info out
      end
    end
  end
end
