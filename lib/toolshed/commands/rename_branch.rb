require 'toolshed/commands/base'
require 'toolshed/git/branch'

class Toolshed::Commands::RenameBranch < Toolshed::Commands::Base
  def self.cli_options
    {
      banner: 'Usage: rename_branch [options]',
      options: {
        branch_name: {
          short_on: '-b'
        },
        new_branch_name: {
          short_on: '-n'
        }
      }
    }
  end

  def execute(args, options = {})
    Toolshed.logger.info "Running toolshed rename_branch with #{options.inspect}"

    options[:branch_name] = options[:branch_name] || read_user_input('Branch name?', required: true)
    new_branch_name = options[:new_branch_name] || read_user_input('New Branch name?', required: true)

    branch = Toolshed::Git::Branch.new(options)
    branch.rename(new_branch_name)
    Toolshed.die
  end
end
