#requires all module files into namespace Moonshine::Base
#also, includes all Moonshine and Crystal modules that it depends on

require "http"
require "time"

module Moonshine
  module Http
    METHODS = %w(GET POST PUT DELETE PATCH)

    require "./parameter_hash"
    require "./request"
    require "./response"
    require "./middleware_response"
    require "./handler"
  end
end
