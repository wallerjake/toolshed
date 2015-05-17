# encoding: UTF-8

module Toolshed
  VERSION = "1.0.2"

  class Version
    def self.banner
      formatted_version = "%80s" % "Version: #{Toolshed::VERSION}"
      formatted_authors_string = "%80s" % "Authors: Jake Waller"
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
