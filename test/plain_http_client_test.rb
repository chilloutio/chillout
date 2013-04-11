require 'test_helper'
require 'chillout/server_side/plain_http_client'

module Chillout
  class PlainHttpClientTest < ChilloutTestCase
    def setup
      @client = PlainHttpClient.new
    end

    def test_post_returns_response_body_json_as_hash
      stub_request(:post, "https://api.chillout.io/projects").to_return(:status => 201, :body => MultiJson.dump(:api_key => "123-123-123"))
      assert_equal "123-123-123", @client.post("/projects", {
        :name => "name"
      })["api_key"]
    end
  end
end
