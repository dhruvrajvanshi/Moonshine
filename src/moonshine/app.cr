require "http"
require "regex"

class Moonshine::App
	# Base class for Moonshine app
	getter server
	getter routes
	getter logger
	getter static_dirs

	def initialize(@static_dirs = [] of String)
		@logger = Moonshine::Logger.new
		@routes = [] of Moonshine::Route
		@error_handlers = {} of Int32 => Request -> Response
	end

	def run(port = 8000)
		# Run the webapp on the specified port
		puts "Moonshine serving at port #{port}..."
		server = HTTP::Server.new(port, BaseHTTPHandler.new(@routes, @static_dirs, @error_handlers))
		server.listen()
	end

	# Add route for all methods to the app
	# Takes in regex pattern and block
	def route(regex, &block : Moonshine::Request -> Moonshine::Response)
		methods = ["GET", "POST", "PUT", "DELETE", "PATCH"]
		methods.each do |method|
			@routes.push Moonshine::Route.new(method, regex, 
				block)
		end
	end

	# Add handler for given error code
	# multiple calls for the same error code result
	# in overriding the previous handler
	def error_handler(error_code, &block : Request -> Response)
		@error_handlers[error_code] = block
	end

	def add_static_dir(path)
		@static_dirs << path
	end

	# methods for adding routes for individual
	# HTTP verbs
	{% for method in %w(get post put delete patch) %}
		def {{method.id}}(path, &block : Moonshine::Request -> Moonshine::Response)
			@routes << Moonshine::Route.new("{{method.id}}".upcase, path.to_s, block)
		end
	{% end %}
end


class Moonshine::BaseHTTPHandler < HTTP::Handler
	# Main HTTP handler class for Moonshine. It's call method
	# is called by the HTTP server when a request is received

	def initialize(@routes,
		@static_dirs = [] of String,
		@error_handlers = {} of Int32 => Moonshine::Request -> Moonshine::Response)
		error_handler 404, do |req|
			Response.new(404, "Page not found")
		end
	end

	def call(base_request : HTTP::Request)
		request = Moonshine::Request.new(base_request)
		# search @routes for matching route
		@routes.each do |route|
			if route.match? (request)
				# controller found
				request.set_params(route.get_params(request))
				response = route.block.call(request).to_base_response()
				
				# check if there's an error handler defined
				if response.status_code >= 400 && @error_handlers.has_key? response.status_code
					return @error_handlers[response.status_code].call(request).to_base_response
				end
				return response
			end
		end

		# Search static dirs
		@static_dirs.each do |dir|
			filepath = File.join(dir, request.path)
			if File.exists?(filepath)
				return HTTP::Response.new(200, File.read(filepath), 
					HTTP::Headers{"Content-Type": mime_type(filepath)})
			end
		end

		# Route match not found return 404 error response
		return @error_handlers[404].call(request).to_base_response
	end

	private def mime_type(path)
	    case File.extname(path)
	    when ".txt" then "text/plain"
	    when ".htm", ".html" then "text/html"
	    when ".css" then "text/css"
	    when ".js" then "application/javascript"
	    else "application/octet-stream"
	    end
	  end

	private def error_handler(error_code, &block : Request -> Response)
		@error_handlers[error_code] = block
	end
end