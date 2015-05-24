include Moonshine::Http
module Shortcuts

  # Returns a Moonshine::Response object
  # from string
  def ok(body)
    Http::Response.new(200, body)
  end

  def not_found(msg=nil)
    Http::Response.new(404, msg="Not found")
  end

  # Returns a Redirect response to the specified
  # location
  def redirect(location)
    res = Http::Response.new(302, "")
    res.headers["Location"] = location
    res
  end
end
