include Moonshine::Http

module Moonshine::Core
  class App < HTTP::Handler
    # Base class for Moonshine app
    getter server
    getter routes
    getter static_dirs


    def initialize(
      @routes       = {} of Route => (Request -> Response) | Controller,
      @request_middleware = [] of Request -> Response?,
      @response_middleware = [] of (Request, Response) -> Response,
      @middleware_objects  = [] of Middleware,
      @controllers         = [] of Controller
    )
    end

    def define
      with self yield
      self # allow chaining
    end

    def run(port = 8000)
      # Run the webapp on the specified port
      puts "Moonshine serving at port #{port}..."
      server = HTTP::Server.new(port, self)
      server.listen()
    end

    def route(regex, &block : Request -> Response)
      METHODS.each do |method|
        @routes[Route.new(method, regex)] = block
      end
      self
    end

    def add_router(router)
      router.each do |route_string, block|
        @routes[Route.new(
          route_string.split(" ")[0],
          route_string.split(" ")[1]
        )] = block
      end
      self
    end

    # Add request middleware. If handler returns a
    # response, no further handlers are called.
    # If nil is returned, the next handler is run
    def request_middleware(&block : Request -> Response?)
      @request_middleware << block
      self
    end

    ##
    # Add response middleware
    def response_middleware(&block : (Request, Response) -> Response)
      @response_middleware << block
      self
    end

    ##
    # Add middleware class. Pass in Middleware instance
    # with overridden process_request and process_response methods
    def middleware_object(instance : Middleware)
      @middleware_objects << instance
      self
    end

    def middleware_objects(objects : Array(Middleware))
      objects.each do |object|
        middleware_object(object)
      end
      self
    end

    def middleware_classes(classes)
      classes.each do |cls|
        middleware_object(cls.new)
      end
      self
    end

    def controller(controller : Controller)
      @controllers << controller
      self
    end

    # methods for adding routes for individual
    # HTTP verbs
    {% for method in %w(get post put delete patch) %}
      def {{method.id}}(path, &block : Request -> Response)
        @routes[Route.new("{{method.id}}".upcase, path.to_s)] = block
        self
      end
    {% end %}

    # overloads for route methods that take in proc as argument
    {% for method in %w(get post put delete patch) %}
      def {{method.id}}(path, block : Request -> Response)
        @routes[Route.new("{{method.id}}".upcase, path.to_s)] = block
        self
      end
    {% end %}

    def call(req)
      request = Request.new(req)
      response = nil

      # call request middleware
      @request_middleware.each do |middleware|
        resp = middleware.call(request)
        if resp
          response = resp as Response
        end
      end

      # Process request with middleware classes
      @middleware_objects.each do |instance|
        response = instance.process_request(request)
      end

      # Check if a controller handles the route
      unless response
        @controllers.each do |controller|
          if controller.handles? request
            response = controller.call(request) as Response
          end
        end
      end

      unless response
        # search @routes for matching route
        @routes.each do |route, block|
          if route.match? (request)
            # controller found
            request.set_params(route.get_params(request))
            response = block.call(request) as Response
            unless response
              next
            end
            # # check if there's an error handler defined
            # if response.status_code >= 400 && @error_handlers.has_key? response.status_code
            #   response = @error_handlers[response.status_code].call(request)
            # end
            break
          end
        end
      end

      unless response
        response = Response.new 404, "Not found"
      end

      response = response as Response

      # apply response middleware
      @response_middleware.each do |middleware|
        response = middleware.call(request, response)
      end

      @middleware_objects.each do |instance|
        instance.process_response(request, response)
      end
      return (response as Response).to_base_response
    end
  end
end