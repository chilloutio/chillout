require 'test_helper'
require 'chillout/server_side/plain_http_client'

module Chillout
  class PlainHttpClientTest < ChilloutTestCase
    def setup
      @client = PlainHttpClient.new
      WebMock.reset!
    end

    def test_post_returns_response_body_json_as_hash
      stub_request(:post, "https://api.chillout.io/projects").to_return(:status => 201, :body => MultiJson.dump(:api_key => "123-123-123"))
      assert_equal "123-123-123", @client.post("/projects", {
        :name => "name"
      })["api_key"]
    end

    def test_post_raises_exception_when_status_code_is_not_201
      stub_request(:post, "https://api.chillout.io/projects").to_return(:status => 403, :body => MultiJson.dump({}))
      assert_raises PlainHttpClient::NotCreated do
        @client.post("/projects", {
          :name => "name"
        })
      end
    end

    def test_post_raises_exception_when_there_is_unpredicted_exception
      stub_request(:post, "https://api.chillout.io/projects").to_raise("great cornholio ate api")
      assert_raises PlainHttpClient::CommunicationError do
        @client.post("/projects", {
          :name => "name"
        })
      end
    end

    def test_customized_host_port_and_ssl
      ENV['CHILLOUT_CLIENT_HOST'] = 'localhost'
      ENV['CHILLOUT_CLIENT_PORT'] = '8080'
      ENV['CHILLOUT_CLIENT_SSL'] = 'false'
      client = PlainHttpClient.new
      assert_equal 'localhost', client.host
      assert_equal 8080, client.port
      assert_equal false, client.ssl
      ENV.delete('CHILLOUT_CLIENT_HOST')
      ENV.delete('CHILLOUT_CLIENT_PORT')
      ENV.delete('CHILLOUT_CLIENT_SSL')
    end
  end
end
