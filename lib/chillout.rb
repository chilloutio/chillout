require "chillout/version"
require "chillout/config"
require "chillout/middleware/creations_monitor"
require "chillout/server-side/dispatcher"
require "chillout/server-side/server_side"
require "chillout/server-side/http_client"
require "chillout/client"

module Chillout
end

require 'chillout/railtie' if defined?(Rails)

