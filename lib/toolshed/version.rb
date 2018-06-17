# encoding: UTF-8

# Module for toolshed
module Toolshed
  VERSION = '1.0.10'

  # Display the version information with the toolshed banner
  class Version
    def self.banner
      formatted_version = format('%80s', "Version: #{Toolshed::VERSION}")
      formatted_authors_string = format('%80s', 'Authors: Jake Waller')
puts <<-EOS
 ______   ___    ___   _       _____ __ __    ___  ___   
|      | /   \  /   \ | |     / ___/|  |  |  /  _]|   \  
|      ||     ||     || |    (   \_ |  |  | /  [_ |    \ 
|_|  |_||  O  ||  O  || |___  \__  ||  _  ||    _]|  D  |
  |  |  |     ||     ||     | /  \ ||  |  ||   [_ |     |
  |  |  |     ||     ||     | \    ||  |  ||     ||     |
  |__|   \___/  \___/ |_____|  \___||__|__||_____||_____|
                                                         
#{formatted_version}
#{formatted_authors_string}
EOS
      exit
    end
  end
end
