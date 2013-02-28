require "chillout/version"
require "chillout/config"
require "chillout/middleware/exception_monitor"
require "chillout/middleware/creations_monitor"
require "chillout/error"
require "chillout/dispatcher"
require "chillout/error_filter"
require "chillout/server_side"
require "chillout/http_client"
require "chillout/client"

module Chillout
end

require 'chillout/railtie' if defined?(Rails)

