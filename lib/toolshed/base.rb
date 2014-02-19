module Toolshed
  class Base
    # implement base methods here
  end
end

String.class_eval do
  def camel_case
    return self if self !~ /_/ && self =~ /[A-Z]+.*/
    split('_').map{|e| e.capitalize}.join
  end
end
