require 'toolshed/base'

module Toolshed
  module Git
    DEFAULT_GIT_TOOL    = 'github'
    DEFAULT_BRANCH_FROM = 'master'

    def branch_name
      git = Toolshed::Git::Base.new
      git.branch_name
    end

    def branched_from
      branched_from = `git rev-parse --abbrev-ref --symbolic-full-name @{u}`.split('/')[-1].strip
    end

    def branch_name_from_id(id)
      branch_name = `git branch | grep \"#{id}\"`.gsub("*", "").strip
    end

    def checkout(branch_name)
      branch_name = Toolshed::Git::Base.branch_name_from_id(branch_name)
      Toolshed::Base.wait_for_command("git checkout #{branch_name} #{Toolshed::Client.instance.git_quiet}")

      unless (Toolshed::Git::Base.git_submodule_command.empty?)
        Toolshed::Base.wait_for_command(Toolshed::Git::Base.git_submodule_command)
      end

      branch_name
    end

    def git_submodule_command
      git_submodule_command = ''
      if (Toolshed::Client.instance.use_git_submodules)
        git_submodule_command = "git submodule update #{Toolshed::Client.instance.git_quiet}"
      end

      git_submodule_command
    end

    def clean_branch_name(branch_name)
      branch_name.strip.downcase.tr(" ", "_").gsub("&", "").gsub(".", "_").gsub("'", "").gsub("__", "_").gsub(":", "").gsub(",", "")
    end

    class GitValidator
      include Veto.validator

      validates :from_remote_name,        :presence => true
      validates :from_remote_branch_name, :presence => true
      validates :to_remote_name,          :presence => true
      validates :to_remote_branch_name,   :presence => true
    end

    class Base
      extend Toolshed::Git

      attr_accessor :from_remote_name, :from_remote_branch_name, :to_remote_name, :to_remote_branch_name, :validator, :passed_branch_name, :force

      def initialize(options={})
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

        self.validator = ::Toolshed::Git::GitValidator.new
        self.passed_branch_name = options[:branch_name] || ''
        self.force = (options.key?(:force_command)) ? '--force' : ''
      end

      def branch_name
        (passed_branch_name.blank?) ? `git rev-parse --abbrev-ref HEAD`.strip : Toolshed::Git::Base.branch_name_from_id(self.passed_branch_name)
      end

      def create_branch
        validator.validate!(self)
        Toolshed.logger.info ''

        new_branch_name = Toolshed::Git::Base.clean_branch_name(to_remote_branch_name)
        Toolshed.logger.info "Creating branch #{new_branch_name} from #{from_remote_name}/#{from_remote_branch_name}"

        remote_update

        results = Toolshed::Base.wait_for_command("git checkout -b #{new_branch_name} #{from_remote_name}/#{from_remote_branch_name} #{Toolshed::Client.instance.git_quiet}")
        results[:stdout] + results[:stderr].each do |out|
          Toolshed.logger.info out
        end

        Toolshed::Base.wait_for_command(Toolshed::Git::Base.git_submodule_command) unless Toolshed::Git::Base.git_submodule_command.empty?

        Toolshed.logger.info ''
        Toolshed.logger.info "Pushing branch #{new_branch_name} to #{from_remote_name}/#{from_remote_branch_name}."
        self.passed_branch_name = new_branch_name
        push

        Toolshed.logger.info ''
        Toolshed.logger.info "Branch #{new_branch_name} has been created from #{from_remote_name}/#{from_remote_branch_name}."
      end

      def delete_branch(delete_branch_name)
        actual_branch_name = Toolshed::Git::Base.branch_name_from_id(delete_branch_name)
        Toolshed.logger.info ''
        Toolshed.logger.info "Deleting branch #{actual_branch_name}"
        Toolshed.logger.info ''
        if actual_branch_name == branch_name
          Toolshed.logger.info 'Checking out master branch'
          Toolshed.logger.info ''
          Toolshed::Git::Base.checkout('master')
        end

        delete_local_branch(actual_branch_name)
        delete_remote_branch(actual_branch_name)
        Toolshed.logger.info ''
        Toolshed.logger.info "Deleted branch #{actual_branch_name}"
      end

      def delete_local_branch(local_branch_name)
        unless local_branches.map { |local_branch| local_branch[:branch_name] }.include?(local_branch_name)
          Toolshed.logger.warn "Unable to delete '#{local_branch_name}' from local as it does not exist skipping"
          return
        end

        results = Toolshed::Base.wait_for_command("git branch -D #{local_branch_name}")
        results[:all].each do |result|
          Toolshed.logger.info result.rstrip
        end
      end

      def delete_remote_branch(remote_branch_name)
        unless remote_branches.include?(remote_branch_name)
          Toolshed.logger.warn "Unable to delete '#{remote_branch_name}' from remote as it does not exist skipping"
          return
        end

        Toolshed.logger.info "Deleting #{remote_branch_name} from remote"
        results = Toolshed::Base.wait_for_command("git push #{Toolshed::Client.instance.push_to_remote_name} --delete #{remote_branch_name}")
        results[:all].each do |result|
          Toolshed.logger.info result.rstrip
        end
      end

      def list_branches
        remote_update
        list_local_branches
        list_remote_branches
      end

      def list_local_branches
        Toolshed.logger.info ''
        Toolshed.logger.info 'Local Branches'
        Toolshed.logger.info ''
        current_branch_name = branch_name
        local_branches.each do |local_branch|
          Toolshed.logger.info "#{local_branch[:branch_name]} #{local_branch[:branch_info]}"
        end
      end

      def list_remote_branches
        Toolshed.logger.info ''
        Toolshed.logger.info 'Remote Branches'
        Toolshed.logger.info ''
        remote_branches.each do |remote_branch|
          Toolshed.logger.info remote_branch
        end
      end

      def local_branches
        @local_branches ||= begin
          local_branches = []
          results = Toolshed::Base.wait_for_command('git branch -avv')
          results[:stdout].each do |stdout|
            next if /remotes.*/.match(stdout) || /HEAD.*/.match(stdout)
            branch_name = /.*\s{3,}/.match(stdout)[0]
            branch_name = branch_name.gsub('*', '')
            branch_info = /\[[a-z].*\]/.match(stdout)[0]
            local_branches << { branch_name: branch_name.lstrip.rstrip, branch_info: branch_info.lstrip.rstrip }
          end
          local_branches
        end
      end

      def remote_branches
        remote_branches = []
        results = Toolshed::Base.wait_for_command('git branch -avv')
        results[:stdout].each do |stdout|
          next unless /remotes\/#{from_remote_name}.*/.match(stdout)
          next if  /.*HEAD.*/.match(stdout)
          matches = /([^\s]+)/.match(stdout)
          remote_branches << matches[0].gsub("remotes/#{from_remote_name}/", '')
        end
        remote_branches
      end

      def remote_update
        results = Toolshed::Base.wait_for_command("git remote update #{Toolshed::Client.instance.git_quiet}")
        results[:all].each do |out|
          Toolshed.logger.info out
        end
      end

      def push
        if branch_name.blank? && !passed_branch_name.blank?
          Toolshed.logger.fatal "Branch #{passed_branch_name} was not found. Unable to push branch."
          Toolshed.die
        end
        result = Toolshed::Base.wait_for_command("git push #{to_remote_name} #{branch_name} #{force} #{Toolshed::Client.instance.git_quiet}")
        result[:all].each do |stdout|
          Toolshed.logger.info stdout
        end
        Toolshed.logger.info 'Everything up-to-date' if result[:stdout].empty? && result[:stderr].empty?
        true
      end
    end
  end
end
