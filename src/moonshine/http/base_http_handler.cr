class BaseHTTPHandler < HTTP::Handler
  # Main HTTP handler class for Moonshine. It's call method
  # is called by the HTTP server when a request is received

  def initialize(@routes = {} of Route => (Request -> Response) | Controller,
    @static_dirs = [] of String,
    @error_handlers = {} of Int32 => Request -> Response,
    @request_middleware = [] of Request -> MiddlewareResponse,
    @response_middleware = [] of (Request, Response) -> Response)
    # add default 404 handler if it isn't there
    unless @error_handlers.has_key? 404
      @error_handlers[404] = ->(request : Request) { Response.new(404, "Not found")}
    end
  end

  def call(base_request : HTTP::Request)
    request = Request.new(base_request)
    response = nil

    # call request middleware
    @request_middleware.each do |middleware|
      optionalresponse = middleware.call(request)
      unless optionalresponse.pass_through
        response = optionalresponse.response
        break
      end
    end

    unless response
      # search @routes for matching route
      @routes.each do |route, block|
        if route.match? (request)
          # controller found
          request.set_params(route.get_params(request))
          response = block.call(request)

          # check if there's an error handler defined
          if response.status_code >= 400 && @error_handlers.has_key? response.status_code
            response = @error_handlers[response.status_code].call(request)
          end
          break
        end
      end
    end

    unless response
      # Search static dirs
      @static_dirs.each do |dir|
        filepath = File.join(dir, request.path)
        if File.exists?(filepath)
          response = Response.new(200, File.read(filepath),
            HTTP::Headers{"Content-Type": mime_type(filepath)})
        end
      end
    end

    unless response
      # Route match not found return 404 error response
      response = @error_handlers[404].call(request)
    end

    # apply response middleware
    @response_middleware.each do |middleware|
      response = middleware.call(request, response)
    end


    return response.to_base_response
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
