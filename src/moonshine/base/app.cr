class App
  # Base class for Moonshine app
  getter server
  getter routes
  getter static_dirs


  def initialize(
    @routes       = {} of Route => (Request -> Response) | Controller,
    @request_middleware = [] of Request -> Response?,
    @response_middleware = [] of (Request, Response) -> Response,
    @middleware_objects  = [] of Middleware::Base,
    @controllers         = [] of Base::Controller
  )

    @handler = Handler.new(@routes, @request_middleware, @response_middleware,
      @middleware_objects, @controllers)
  end

  def define
    with self yield
    self # allow chaining
  end

  def run(port = 8000)
    # Run the webapp on the specified port
    puts "Moonshine serving at port #{port}..."
    server = HTTP::Server.new(port, @handler as Handler)
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
  # Add middleware class. Pass in Middleware::Base instance
  # with overridden process_request and process_response methods
  def middleware_object(instance : Middleware::Base)
    @middleware_objects << instance
    self
  end

  def middleware_objects(objects : Array(Middleware::Base))
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
    @handler.call req
  end
end
