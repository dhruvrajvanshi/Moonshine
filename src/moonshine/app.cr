require "http"
require "regex"

class Moonshine::App
	# Base class for Moonshine app
	getter server
	getter routes

	def initialize()
		@logger = Moonshine::Logger.new
		@routes = [] of Moonshine::Route
		@static_dirs = nil
	end

	def route(regex, controller_class)
		# add route to @routes by instantiating the controller
		# class
		@routes.push Moonshine::Route.new(regex, 
			controller_class.new)
	end

	def run(port = 8000)
		# Run the webapp on the specified port
		puts "Moonshine serving at port #{port}..."
		server = HTTP::Server.new(port, BaseHTTPHandler.new(@routes))
		server.listen()
	end
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
			if route.match? (request.path)
				# controller found
				request.set_params(route.get_params(request.path))
				return route.controller.handle(request).to_base_response()
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