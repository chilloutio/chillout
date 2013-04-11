require 'test_helper'
require 'chillout/registration'

module Chillout
  class RegistrationTest < ChilloutTestCase
    def setup
      @http_client = mock("http_client")
      @registration = Registration.new(@http_client)
    end

    def test_register_send_name_and_emails
      @http_client.expects(:post).with("/projects", has_entries(:name => "name of project", :emails => ["kaka@dada.com", "dada@kaka.com"])).returns("")
      @registration.register("name of project", ["kaka@dada.com", "dada@kaka.com"])
    end

    def test_register_returns_stripped_response_body_as_result
      @http_client.stubs(:post).returns("  123-123-123  ")
      assert_equal "123-123-123", @registration.register("name of project", ["kaka@dada.com", "dada@kaka.com"])
    end
  end
end
