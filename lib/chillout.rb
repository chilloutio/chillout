require "chillout/version"
require "chillout/config"
require "chillout/middleware/creations_monitor"
require "chillout/dispatcher"
require "chillout/server_side"
require "chillout/http_client"
require "chillout/client"

module Chillout
end

require 'chillout/railtie' if defined?(Rails)

