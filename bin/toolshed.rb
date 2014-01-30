#!/usr/bin/env ruby

$:.unshift(File.dirname(__FILE__) + '/../lib')
require 'toolshed'

def usage
  $stderr.puts <<EOF
    This is some sample usage documentation
EOF
end

if $0.split("/").last == 'toolshed'
  command = ARGV.shift
  if command.nil? || command == 'help'
    usage
  else
    options_parser = subcommands[command]
    options_parser.order! if options_parser
    begin
      cli.execute(command, ARGV, options)
    rescue Toolshed::CommandNotFound => e
      puts e.message
    end
  end
end
