module Moonshine
  module Exceptions
    VERSION = "0.0.1"

    class MoonshineException < Exception
	end

	class HttpException < MoonshineException
	end

	class KeyNotFound < HttpException
		def initialize(key)
			super("Key '#{key}' not found in hash")
		end
	end

  end
end
