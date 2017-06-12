require 'test_helper'

class ClientSendsMetricsTest < AcceptanceTestCase

  def test_client_sends_metrics
    test_app      = TestApp.new
    test_endpoint = TestEndpoint.new
    test_user     = TestUser.new

    test_endpoint.listen
    test_app.boot
    assert test_endpoint.has_received_information_about_startup
    test_user.create_entity('Myrmecophagidae')
    assert test_endpoint.has_one_creation_for_entity_resource
  ensure
    test_app.shutdown if test_app
  end

end
