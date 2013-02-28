require 'test_helper'

module Chillout
  class HttpClientTest < ChilloutTestCase
    def test_post_raises_not_sent_exception_when_get_any_error
      logger = stub(error: nil)
      http_client = HttpClient.new(:wrong_config, logger)
      assert_raises HttpClient::NotSent do
        http_client.post("/events", {fake_data: "client"})
      end
    end
  end
end
