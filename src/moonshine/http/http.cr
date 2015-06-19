#requires all module files into namespace Moonshine::Base
#also, includes all Moonshine and Crystal modules that it depends on

require "http"
require "time"

include Moonshine::Exceptions

module Moonshine
  module Http
    VERSION = "0.0.1"
    METHODS = %w(GET POST PUT DELETE PATCH)

    require "./parameter_hash"
    require "./request"
    require "./response"
    require "./middleware_response"
  end
end
