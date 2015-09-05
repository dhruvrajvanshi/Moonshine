#requires all module files into namespace Moonshine::Base
#also, includes all Moonshine and Crystal modules that it depends on

require "http"
require "time"

require "./request"
require "./response"

module Moonshine
  module Http
    METHODS = %w(GET POST PUT DELETE PATCH)
  end
end
