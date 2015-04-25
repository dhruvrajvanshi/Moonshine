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
	end

	def run(port = 8000)
		# Run the webapp on the specified port
		puts "Moonshine serving at port #{port}..."
		server = HTTP::Server.new(port, BaseHTTPHandler.new(@routes, @static_dirs))
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
		@static_dirs = [] of String)
	end

	def call(base_request : HTTP::Request)
		request = Moonshine::Request.new(base_request)
		# search @routes for matching route
		@routes.each do |route|
			if route.match? (request)
				# controller found
				request.set_params(route.get_params(request))
				return route.block.call(request).to_base_response()
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
		return HTTP::Response.new(404,
					"<html><body>
						<h1>404</h1><hr>
						#{request.path} not found</body></html>")
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
end