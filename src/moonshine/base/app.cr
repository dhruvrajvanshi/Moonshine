require "http"
require "regex"
include Moonshine::Http

module Moonshine
  class App
    # Base class for Moonshine app
    getter server
    getter routes
    getter logger
    getter static_dirs


    def initialize(
      @static_dirs = [] of String,
      @routes = {} of Moonshine::Route => (Request -> Response) | Controller,
      @error_handlers = {} of Int32 => Request -> Response,
      @request_middleware = [] of Request -> MiddlewareResponse,
      @response_middleware = [] of (Request, Response) -> Response)
      @logger = Moonshine::Logger.new
      # add default 404 handler
      error_handler 404, do |req|
        Response.new(404, "Page not found")
      end
    end

    def define
      with self yield
      self # allow chaining
    end

    def run(port = 8000)
      # Run the webapp on the specified port
      puts "Moonshine serving at port #{port}..."
      server = HTTP::Server.new(port, BaseHTTPHandler.new(@routes, @static_dirs,
        @error_handlers, @request_middleware, @response_middleware))
      server.listen()
    end

    def route(regex, &block : Request -> Response)
      Moonshine::Http::METHODS.each do |method|
        @routes[Moonshine::Route.new(method, regex)] = block
      end
    end

    def add_router(router)
      router.each do |route_string, block|
        @routes[Route.new(
          route_string.split(" ")[0],
          route_string.split(" ")[1]
        )] = block
      end
    end

    # Add request middleware. If handler returns a
    # response, no further handlers are called.
    # If nil is returned, the next handler is run
    def request_middleware(&block : Request -> MiddlewareResponse)
      @request_middleware << block
    end

    ##
    # Add response middleware
    def response_middleware(&block : (Request, Response) -> Response)
      @response_middleware << block
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

    def controller(path, controller : Controller)
      @routes[Route.new("", path)] = controller
    end

    def controller(paths : Array(String), controller : Controller)
      paths.each do |path|
        controller(path, controller)
      end
    end

    # methods for adding routes for individual
    # HTTP verbs
    {% for method in %w(get post put delete patch) %}
      def {{method.id}}(path, &block : Request -> Response)
        @routes[Moonshine::Route.new("{{method.id}}".upcase, path.to_s)] = block
      end
    {% end %}
  end
end
