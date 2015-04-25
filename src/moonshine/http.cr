require "http"

class Moonshine::Request
	getter params
	getter path
	getter method
	getter version
	getter body
	getter headers

	def initialize(request : HTTP::Request)
		@path = request.path
		@method = request.method
		@version = request.version
		@body    = request.body
		@headers = request.headers
		@params = {} of String => String
	end

	def set_params(par)
		@params = par
	end
end

class Moonshine::Response
	getter status_code
	getter body
	getter headers

	def initialize(@status_code, @body, @version = "HTTP/1.1")
		@headers = HTTP::Headers.new
	end

	def set_header(key, value)
		@headers[key] = value
	end

	def to_base_response()
		return HTTP::Response.new(@status_code, @body, 
			headers = @headers, version = @version)
	end
end