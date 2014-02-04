module Toolshed
  module Git
    DEFAULT_GIT_TOOL = 'github'

    def initialize(options={})
    end

    def self.branch_name
      # branch information
      branch_name = `git rev-parse --abbrev-ref HEAD`.strip
    end

    def self.branched_from
      branched_from = `git rev-parse --abbrev-ref --symbolic-full-name @{u}`.split('/')[-1].strip
    end

    def self.branch_name_from_id(id)
      branch_name = `git branch | grep \"#{ticket_id}\"`.gsub("*", "").strip
    end
  end
end
