require "http"
require "time"

class Moonshine::Request
	getter params
	getter path
	getter method
	getter version
	property body
	property headers
	getter cookies

	def initialize(request : HTTP::Request)
		@path = request.path
		@method = request.method
		@version = request.version
		@body    = request.body
		@headers = request.headers
		@params = {} of String => String
		@cookies = {} of String => String
		parse_cookies()
	end

	def set_params(par)
		@params = par
	end

	def parse_cookies()
		if @headers.has_key? "Cookie"
			@headers["Cookie"].split(";").each do |cookie|
				key = cookie.strip().split("=")[0]
				value = cookie.strip().split("=")[1]
				@cookies[key] = value
			end
		end
	end
end

class Moonshine::Response
	getter status_code
	getter body
	setter body
	getter headers
	getter cookies
	setter cookies

	def initialize(@status_code, @body, @headers = HTTP::Headers.new, @version = "HTTP/1.1", @cookies = {} of String => String)
	end

	def set_header(key, value)
		@headers[key] = value
	end


	def to_base_response()
		# unless @cookies.empty?
		# 	cookie_string = serialize_cookies()
		# 	@headers["Set-Cookie"] = cookie_string
		# end
		return HTTP::Response.new(@status_code, @body, 
			headers = @headers, version = @version)
	end

	# TODO : Add expiry
	def set_cookie(key, value, @secure = false, @http_only = false)
		cookie_string = "#{key}=#{value}"
		if @secure
			cookie_string += "; secure"
		end
		if @http_only
			cookie_string += "; HttpOnly"
		end
		headers.add("Set-Cookie", cookie_string)
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