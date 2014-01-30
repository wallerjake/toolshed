module Toolshed
  class Error < StandardError
  end

  class RecordExists < Error
  end

  class RecordNotFoundError < Error
  end

  class AuthenticationFailed < Error
  end
end
