require "http"
require "time"

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
	getter cookies
	setter cookies

	def initialize(@status_code, @body, @version = "HTTP/1.1", @cookies = {} of String => String)
		@headers = HTTP::Headers.new
	end

	def set_header(key, value)
		@headers[key] = value
	end


	def to_base_response()
		unless @cookies.empty?
			cookie_string = serialize_cookies()
			@headers["Set-Cookie"] = cookie_string
		end
		return HTTP::Response.new(@status_code, @body, 
			headers = @headers, version = @version)
	end

	def serialize_cookies()
		cookie_string = ""
		@cookies.each do |key, value|
			cookie_string += key + "=" + value + ", "
		end
		cookie_string = cookie_string[0..-2]
		cookie_string
	end
end

class Moonshine::MiddlewareResponse
	##
	# Return type for request middleware
	# if @pass_through is true the next middleware
	# will be called. Otherwise, Response will be
	# returned 

	getter response
	getter pass_through

	def initialize(@response = Response.new(200, "Ok"),
		@pass_through = true)
	end
end