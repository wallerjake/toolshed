require 'veto'

module Toolshed
  class Git
    class Validator
      include Veto.validator

      validates :from_remote_name,        :presence => true
      validates :from_remote_branch_name, :presence => true
      validates :to_remote_name,          :presence => true
      validates :to_remote_branch_name,   :presence => true
    end
  end
end
