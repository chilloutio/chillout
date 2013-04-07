require "chillout/version"
require "chillout/config"
require "chillout/middleware/creations_monitor"
require "chillout/server_side/dispatcher"
require "chillout/server_side/server_side"
require "chillout/server_side/http_client"
require "chillout/client"

module Chillout
end

require 'chillout/railtie' if defined?(Rails)

