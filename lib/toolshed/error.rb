module Toolshed
  class Error < StandardError; end
  class RecordExists < Error; end
  class RecordNotFoundError < Error; end
  class AuthenticationFailed < Error; end
  class SSHResponseException < Error; end
  class CorruptFileException < StandardError; end
end
