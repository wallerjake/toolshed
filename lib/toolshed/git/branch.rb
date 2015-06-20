require 'toolshed/git'

module Toolshed
  class Git
    class Branch < Toolshed::Git
      def initialize(options = {})
        super(options)
      end

      # class methods

      class << self
        def ask_which_branch(branch_names)
          selected_branch_name = ''
          choose do |menu|
            menu.prompt = "Multiple branches matched input branch name. Which branch are you looking for?  "

            branch_names.each do |branch_name|
              menu.choice(branch_name.to_sym, branch_name) do |branch_name|
                selected_branch_name = branch_name
              end
            end
          end
          selected_branch_name.to_s
        end

        def from
          `git rev-parse --abbrev-ref --symbolic-full-name @{u}`.split('/')[-1].strip
        end

        def checkout(checkout_branch_name)
          Toolshed.logger.info ''
          Toolshed.logger.info "Looking for branch #{checkout_branch_name}"
          actual_branch_name = Toolshed::Git::Branch.name_from_substring(checkout_branch_name)
          Toolshed.logger.info "Switching to branch #{actual_branch_name}"
          result = Toolshed::Base.wait_for_command("git checkout #{actual_branch_name} #{Toolshed::Client.instance.git_quiet}")
          if /.*Your local changes to the following files would be overwritten by checkout.*/.match(result[:stderr][0])
            Toolshed.logger.fatal "Unable to checkout branch due to the following error(s) #{result[:all].join(', ')}"
            Toolshed.die
          end
          Toolshed::Base.wait_for_command(Toolshed::Git.git_submodule_command) unless Toolshed::Git.git_submodule_command.empty?
          Toolshed.logger.info "Switched to branch #{actual_branch_name}"
          actual_branch_name
        end

        def name
          branch = Toolshed::Git::Branch.new
          branch.name
        end

        def name_from_substring(substring)
          branches = Toolshed::Base.wait_for_command("git branch | grep \"#{substring}\"")
          branch_names = branches[:all].map { |branch_name| branch_name.gsub('*', '').strip }

          return substring if branch_names.length == 0
          return branch_names.first if branch_names.length == 1
          Toolshed::Git::Branch.ask_which_branch(branch_names)
        end
      end

      # instance methods

      def create
        validator.validate!(self)
        Toolshed.logger.info ''

        new_branch_name = Toolshed::Git.clean_branch_name(to_remote_branch_name)
        Toolshed.logger.info "Creating branch #{new_branch_name} from #{from_remote_name}/#{from_remote_branch_name}"

        remote_update
        results = Toolshed::Base.wait_for_command("git checkout -b #{new_branch_name} #{from_remote_name}/#{from_remote_branch_name} #{Toolshed::Client.instance.git_quiet}")
        results[:all].each do |out|
          if out.match(/.*fatal.*/)
            Toolshed.logger.fatal out
            Toolshed.die
          else
           Toolshed.logger.info out
          end
        end
        Toolshed::Base.wait_for_command(Toolshed::Git.git_submodule_command) unless Toolshed::Git.git_submodule_command.empty?

        Toolshed.logger.info ''
        Toolshed.logger.info "Pushing branch #{new_branch_name} to #{from_remote_name}/#{from_remote_branch_name}."
        self.passed_branch_name = new_branch_name
        push

        Toolshed.logger.info ''
        Toolshed.logger.info "Branch #{new_branch_name} has been created from #{from_remote_name}/#{from_remote_branch_name}."
      end

      def delete(delete_branch_name)
        actual_branch_name = Toolshed::Git::Branch.name_from_substring(delete_branch_name)
        Toolshed.logger.info ''
        Toolshed.logger.info "Deleting branch '#{actual_branch_name}'"
        if actual_branch_name == name
          Toolshed.logger.info 'Checking out master branch'
          Toolshed.logger.info ''
          Toolshed::Git::Branch.checkout('master')
        end

        delete_local(actual_branch_name)
        delete_remote(actual_branch_name)
        Toolshed.logger.info ''
        Toolshed.logger.info "Deleted branch #{actual_branch_name}"
      end

      def delete_local(local_branch_name)
        unless local.map { |local_branch| local_branch[:branch_name] }.include?(local_branch_name)
          Toolshed.logger.warn "Unable to delete '#{local_branch_name}' from local as it does not exist skipping"
          return
        end

        results = Toolshed::Base.wait_for_command("git branch -D #{local_branch_name}")
        results[:all].each do |result|
          Toolshed.logger.info result.rstrip
        end
      end

      def delete_remote(remote_branch_name)
        unless remote.include?(remote_branch_name)
          Toolshed.logger.warn "Unable to delete '#{remote_branch_name}' from remote as it does not exist skipping"
          return
        end

        Toolshed.logger.info "Deleting #{remote_branch_name} from remote"
        results = Toolshed::Base.wait_for_command("git push #{Toolshed::Client.instance.push_to_remote_name} --delete #{remote_branch_name}")
        results[:all].each do |result|
          Toolshed.logger.info result.rstrip
        end
      end

      def list
        remote_update
        list_local
        list_remote
      end

      def list_local
        Toolshed.logger.info ''
        Toolshed.logger.info 'Local Branches'
        Toolshed.logger.info ''
        current_branch_name = name
        local.each do |local_branch|
          Toolshed.logger.info "#{local_branch[:branch_name]} #{local_branch[:branch_info]}"
        end
      end

      def list_remote
        Toolshed.logger.info ''
        Toolshed.logger.info 'Remote Branches'
        Toolshed.logger.info ''
        remote.each do |remote_branch|
          Toolshed.logger.info remote_branch
        end
      end

      def local
        @local ||= begin
          local_branches = []
          results = Toolshed::Base.wait_for_command('git branch -avv')
          results[:stdout].each do |stdout|
            next if /remotes.*/.match(stdout) || /HEAD.*/.match(stdout)
            branch_name = /.*\s{3,}/.match(stdout)[0]
            branch_name = branch_name.gsub('*', '')
            branch_info_match = /\[[a-z].*\]/.match(stdout)
            branch_info = ''
            branch_info = branch_info_match[0] unless branch_info_match.nil?
            local_branches << { branch_name: branch_name.lstrip.rstrip, branch_info: branch_info.lstrip.rstrip }
          end
          local_branches
        end
      end

      def name
        (passed_branch_name.nil? || passed_branch_name.empty?) ? `git rev-parse --abbrev-ref HEAD`.strip : Toolshed::Git::Branch.name_from_substring(passed_branch_name) # rubocop:disable Metrics/LineLength
      end

      def push
        Toolshed.logger.info "Pushing #{name}"
        if (name.nil? || name.empty?) && (!passed_branch_name.nil? && !passed_branch_name.empty?)
          Toolshed.logger.fatal "Branch #{passed_branch_name} was not found. Unable to push branch."
          Toolshed.die
        end
        result = Toolshed::Base.wait_for_command("git push #{to_remote_name} #{name} #{force} #{Toolshed::Client.instance.git_quiet}")
        result[:all].each do |stdout|
          Toolshed.logger.info stdout
        end
        Toolshed.logger.info 'Everything up-to-date' if result[:stdout].empty? && result[:stderr].empty?
        Toolshed.logger.info "#{name} has been pushed"
      end

      def remote
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

      def rename(new_branch_name)
        current_branch_name = passed_branch_name
        results = Toolshed::Base.wait_for_command("git branch -m #{passed_branch_name} #{new_branch_name}")
        results[:all].each do |out|
          matches = /(error.*|fatal.*)/.match(out)
          if matches.length > 0
            Toolshed.logger.fatal out
            Toolshed.die("Unable to proceed supplied branch '#{current_branch_name}' does not exist in local repository.")
          else
            Toolshed.logger.info out
          end
        end
        self.passed_branch_name = new_branch_name
        push
        delete_remote(current_branch_name)
        Toolshed.logger.info ''
        Toolshed.logger.info "Deleted branch #{current_branch_name}"
      end
    end
  end
end
