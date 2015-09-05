class Handler < HTTP::Handler
  # Main HTTP handler class for Moonshine. It's call method
  # is called by the HTTP server when a request is received

  def initialize(@routes = {} of Route => (Request -> Response) | Controller,
    @request_middleware = [] of Request -> Response?,
    @response_middleware = [] of (Request, Response) -> Response,
    @middleware_objects  = [] of Middleware::Base,
    @controllers         = [] of Controller
    )
  end

  def call(base_request : HTTP::Request)
    request = Request.new(base_request)
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
      instance.process_request(request)
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

    # apply response middleware
    @response_middleware.each do |middleware|
      response = middleware.call(request, response as Response)
    end

    @middleware_objects.each do |instance|
      instance.process_response(request, response as Response)
    end


    return (response as Response).to_base_response
  end
end
