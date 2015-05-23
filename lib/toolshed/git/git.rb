module Toolshed
  module Git
    DEFAULT_GIT_TOOL    = 'github'
    DEFAULT_BRANCH_FROM = 'master'

    def branch_name
      # branch information
      branch_name = `git rev-parse --abbrev-ref HEAD`.strip
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

    def delete(branch_name)
      branch_name = Toolshed::Git::Base.branch_name_from_id(branch_name)

      # if delete your current branch checkout master so it can be deleted
      if (branch_name == Toolshed::Git::Base.branch_name)
        Toolshed::Git::Base.checkout('master')
      end

      Toolshed::Base.wait_for_command("git push #{Toolshed::Client.instance.push_to_remote_name} :#{branch_name}; git branch -D #{branch_name}")

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

    def push(options = {})
      branch_name = (options.has_key?(:branch_name)) ? Toolshed::Git::Base.branch_name_from_id(options[:branch_name]) : Toolshed::Git::Base.branch_name
      force_command = (options.has_key?(:force_command)) ? '--force' : ''
      Toolshed::Base.wait_for_command("git push #{Toolshed::Client.instance.push_to_remote_name} #{branch_name} #{force_command}")

      branch_name
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

      attr_accessor :from_remote_name, :from_remote_branch_name, :to_remote_name, :to_remote_branch_name, :validator

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
      end

      def create_branch
        self.validator.validate!(self)

        new_branch_name = Toolshed::Git::Base.clean_branch_name(self.to_remote_branch_name)
        Toolshed::Base.wait_for_command("git remote update #{Toolshed::Client.instance.git_quiet}")

        Toolshed::Base.wait_for_command("git checkout -b #{new_branch_name} #{self.from_remote_name}/#{self.from_remote_branch_name} #{Toolshed::Client.instance.git_quiet}")

        unless (Toolshed::Git::Base.git_submodule_command.empty?)
          Toolshed::Base.wait_for_command(Toolshed::Git::Base.git_submodule_command)
        end

        Toolshed::Base.wait_for_command("git push #{self.to_remote_name} #{new_branch_name} #{Toolshed::Client.instance.git_quiet}")
      end
    end
  end
end
