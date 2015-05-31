require 'toolshed/commands/base'

class Toolshed::Commands::PushBranch < Toolshed::Commands::Base
  def initialize(options = {})
    super(options)
  end

  def self.cli_options
    {
      banner: 'Usage: push_branch [options]',
      options: {
        force_command: {
          short_on: '-f',
          default: true
        },
        branch_name: {
          short_on: '-b'
        }
      }
    }
  end

  def execute(args, options = {})
    Toolshed.logger.info "Running toolshed push_branch with #{options.inspect}"
    git = Toolshed::Git::Base.new(options)
    git.push_branch
    Toolshed.die
  end
end
