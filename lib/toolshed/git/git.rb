module Toolshed
  module Git
    DEFAULT_GIT_TOOL = 'github'

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
      system("git checkout #{branch_name} #{Toolshed::Client.git_quiet}; #{Toolshed::Git::Base.git_submodule_command}")
    end

    def git_submodule_command
      git_submodule_command = ''
      if (Toolshed::Client.use_git_submodules)
        print "Update Submodules (y/n)? "
        update_submodules = $stdin.gets.chomp
        if (update_submodules == 'y')
          git_submodule_command = "git submodule update --init;"
        end
      end

      git_submodule_command
    end

    def clean_branch_name(branch_name)
      branch_name.strip.downcase.tr(" ", "_").gsub("-", "").gsub("&", "").gsub("/", "_").gsub(".", "_").gsub("'", "").gsub("__", "_").gsub(":", "")
    end

    # code specific to commands prompts included
    def create_branch_command
      print "Branch text? "
      branch_name = $stdin.gets.chomp

      print "Branch from? "
      branch_from = $stdin.gets.chomp

      git = Toolshed::Git::Base.new({
        from_remote_branch_name: branch_from,
        to_remote_branch_name: branch_name,
      })

      puts 'Creating Branch ...'
      git.create_branch
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
        self.from_remote_name = Toolshed::Client.pull_from_remote_name
        unless (options[:from_remote_name].nil?)
         self.from_remote_name  = options[:from_remote_name]
        end

        self.to_remote_name = Toolshed::Client.push_to_remote_name
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
        system("git remote update #{Toolshed::Client.git_quiet}; git checkout -b #{new_branch_name} #{self.from_remote_name}/#{self.from_remote_branch_name} #{Toolshed::Client.git_quiet}; #{Toolshed::Git::Base.git_submodule_command} git push #{self.to_remote_name} #{new_branch_name} #{Toolshed::Client.git_quiet};")
      end
    end
  end
end
