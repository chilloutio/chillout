require 'test_helper'
require 'chillout/registration'

module Chillout
  class RegistrationTest < ChilloutTestCase
    def setup
      @http_client = mock("http_client")
      @registration = Registration.new(@http_client)
    end

    def test_register_send_name_and_emails
      @http_client.expects(:post).with("/projects", has_entries(:name => "name of project", :emails => ["kaka@dada.com", "dada@kaka.com"])).returns({"api_key" => "123-123-123"})
      @registration.register("name of project", ["kaka@dada.com", "dada@kaka.com"])
    end

    def test_register_returns_stripped_response_body_as_result
      @http_client.stubs(:post).returns({"api_key" => "   123-123-123  "})
      assert_equal "123-123-123", @registration.register("name of project", ["kaka@dada.com", "dada@kaka.com"])
    end

    def test_raises_exception_when_it_receives_info_about_crossed_limit
      exception = stub_not_created("403")
      @http_client.stubs(:post).raises(exception)
      assert_raises Registration::NotRegisteredByLimit do
        @registration.register("name of project", ["kaka@dada.com", "dada@kaka.com"])
      end
    end

    def test_raises_exception_when_it_receives_info_about_invalid_data
      exception = stub_not_created("400")
      @http_client.stubs(:post).raises(exception)
      assert_raises Registration::NotRegisteredByInvalidData do
        @registration.register("name of project", ["kaka@dada.com", "dada@kaka.com"])
      end
    end

    def test_raises_exception_when_it_receives_other_failure_response
      exception = stub_not_created("402")
      @http_client.stubs(:post).raises(exception)
      assert_raises Registration::NotRegisteredByAccident do
        @registration.register("name of project", ["kaka@dada.com", "dada@kaka.com"])
      end
    end

    def test_raises_exception_when_commucation_error_occures
      exception = PlainHttpClient::CommunicationError.new(:e)
      @http_client.stubs(:post).raises(exception)
      assert_raises Registration::NotRegisteredByCommunicationError do
        @registration.register("name of project", ["kaka@dada.com", "dada@kaka.com"])
      end
    end

    def stub_not_created(code)
      response = stub(:code => code)
      PlainHttpClient::NotCreated.new(response)
    end
  end
end
