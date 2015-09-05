include Moonshine::Http
module Moonshine::Utils::Shortcuts
  # Returns a Moonshine::Response object
  # from string
  def ok(body)
    Response.new(200, body)
  end

  def not_found(msg=nil)
    Response.new(404, msg="Not found")
  end

  def not_found(msg=nil)
    Response.new(404, msg)
  end

  # Returns a Redirect response to the specified
  # location
  def redirect(location)
    res = Response.new(302, "")
    res.headers["Location"] = location
    res
  end
end
