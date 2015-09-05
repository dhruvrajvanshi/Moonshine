# Requires all module files into namespace Moonshine::Utils
# Also, includes all Moonshine and Crystal modules that it depends on

require "time"

module Moonshine
  module Utils
    require "./shortcuts"   # inner module : Moonshine::Utils::Shortcuts
    require "./http_logger"
  end
end
