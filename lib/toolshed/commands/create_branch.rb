module Toolshed
  module Commands
    class CreateBranch
      def self.cli_options
        {
          banner: 'Usage: create_branch [options]',
          options: {
            branch_name: {
              short_on: '-b',
            },
            branch_from: {
              short_on: '-f'
            }
          }
        }
      end

      def execute(args, options = {})
        begin
          branch_name = read_user_input_branch_name("Branch name:", options)
          branch_from = read_user_input_branch_from("Branch from:", options)

          git = Toolshed::Git::Base.new({
            from_remote_branch_name: branch_from,
            to_remote_branch_name: branch_name,
          })
          git.create_branch
          Toolshed.die
        rescue Veto::InvalidEntity => e
          puts "Unable to create branch due to the following errors"
          e.message.each do |key, value|
            puts "#{key}: #{value}"
          end
          Toolshed.die
        end
      end

      def read_user_input_branch_name(message, options)
        return options[:branch_name] if options.key?(:branch_name)

        puts message
        value = $stdin.gets.chomp

        until (!value.empty?)
          puts "Branch name cannot be empty"
          puts message
          value = $stdin.gets.chomp
        end

        value
      end

      def read_user_input_branch_from(message, options)
        return options[:branch_from] if (options.has_key?(:branch_from))

        # if branch-name was supplied then default to master if not supplied
        return Toolshed::Git::DEFAULT_BRANCH_FROM if options.key?(:branch_name)

        puts message
        value = $stdin.gets.chomp

        until (!value.empty?)
          puts "Branch from cannot be empty"
          puts message
          value = $stdin.gets.chomp
        end

        value
      end
    end
  end
end
