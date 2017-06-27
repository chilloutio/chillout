require 'test_helper'

class ClientSendsMetricsTest < AcceptanceTestCase

  def test_client_sends_metrics
    test_app      = TestApp.new
    test_endpoint = TestEndpoint.new(port: 8080)
    test_user     = TestUser.new

    test_endpoint.listen
    test_app.boot(chillout_port: 8080)
    if ENV['STRATEGY'] != 'active_job'
      assert test_endpoint.has_received_information_about_startup
    end
    test_user.create_entity('Myrmecophagidae')
    assert creation = test_endpoint.has_one_creation_for_entity_resource
    assert_equal "Entity", creation["measurements"][0]["series"]
  ensure
    test_app.shutdown if test_app
  end

end
