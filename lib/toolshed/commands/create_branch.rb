module Toolshed
  module Commands
    class CreateBranch
      def execute(args, options = {})
        begin
          branch_name = read_user_input_branch_name("Branch name:", options)
          branch_from = read_user_input_branch_from("Branch from:", options)

          puts "Branch name: #{branch_name}"
          puts "Branching from: #{branch_from}"

          git = Toolshed::Git::Base.new({
            from_remote_branch_name: branch_from,
            to_remote_branch_name: branch_name,
          })
          git.create_branch

          puts "Branch #{branch_name} has been created"
          return
        rescue Veto::InvalidEntity => e
          puts "Unable to create branch due to the following errors"
          e.message.each do |key, value|
            puts "#{key}: #{value}"
          end
          return
        end
      end

      def read_user_input_branch_name(message, options)
        return options[:branch_name] if (options.has_key?(:branch_name))

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
        if (options.has_key?(:branch_name))
          return Toolshed::Git::DEFAULT_BRANCH_FROM
        end

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
