class MiddlewareResponse
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
