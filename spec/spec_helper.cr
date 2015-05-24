require "spec"
require "../src/moonshine"

include Moonshine::Base
include Moonshine::Http
include Moonshine::Utils
include Moonshine::Utils::Shortcuts

# Helper method
def new_request(method, path)
  Request.new(
    HTTP::Request.new(method, path))
end

class EmptyCallable
  def initialize(@text = "")
  end

  def call(request : Request)
    Response.new(200, @text)
  end
end
