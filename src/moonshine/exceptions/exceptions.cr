module Moonshine
  module Exceptions

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
