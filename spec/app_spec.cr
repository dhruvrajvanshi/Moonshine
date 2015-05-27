require "./spec_helper"
require "http"

class HelloController < Controller
  def get(req)
    ok("hello")
  end
end

describe Handler do
  it "returns 404" do
    handler = Handler.new ({} of Route => Request -> Response)
    req = HTTP::Request.new("GET", "/")
    res = handler.call(req)
    res.status_code.should eq (404)
  end

  it "handles get request" do
    handler = Handler.new ({
      Route.new("GET", "/") => HelloController.new
    } of Route => (Request -> Response) | Controller)

    req = HTTP::Request.new("GET", "/")
    res = handler.call(req)
    res.status_code.should eq (200)
    res.body.should eq("hello")
  end

  it "returns static file" do
    handler = Handler.new({} of Route => Request -> Response,
      ["spec/res"])
    req = HTTP::Request.new("GET", "/static.txt")
    res = handler.call(req)
    res.status_code.should eq(200)
    res.body.should eq("hello")
  end

  it "returns 405 when controller method not defined" do
    routes = {} of Route => (Request -> Response) | Controller
    routes[Route.new("", "/")] = HelloController.new
    handler = Handler.new(routes)
    res = handler.call(HTTP::Request.new("POST", "/"))
    res.status_code.should eq 405
  end
end
