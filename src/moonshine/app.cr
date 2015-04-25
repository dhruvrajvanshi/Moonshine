require "http"
require "regex"

class Moonshine::App
	# Base class for Moonshine app
	getter server
	getter routes
	getter logger

	def initialize()
		@logger = Moonshine::Logger.new
		@routes = [] of Moonshine::Route
		@static_dirs = nil
	end

	def run(port = 8000)
		# Run the webapp on the specified port
		puts "Moonshine serving at port #{port}..."
		server = HTTP::Server.new(port, BaseHTTPHandler.new(@routes))
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

	def initialize(@routes)
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

		# TODO: Search static dirs

		# Route match not found return 404 error response
		return HTTP::Response.new(404,
					"<html><body>
						<h1>404</h1><hr>
						#{request.path} not found</body></html>")
	end
end