require 'test_helper'
require 'time'

class ServerSideTest < ChilloutTestCase

  def setup
    @event_data_builder = mock("EventDataBuilder")
    @http_client = mock("HttpClient")
    @server_side = Chillout::ServerSide.new(@event_data_builder, @http_client)
  end
end
