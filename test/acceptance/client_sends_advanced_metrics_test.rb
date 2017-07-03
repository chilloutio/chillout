require 'test_helper'

class ClientSendsAdvancedMetricsTest < AcceptanceTestCase

  def test_client_sends_advanced_metrics
    test_app      = TestApp.new
    test_endpoint = TestEndpoint.new(port: 8084)
    test_user     = TestUser.new

    test_endpoint.listen
    test_app.boot(chillout_port: 8084)
    if ENV['STRATEGY'] != 'active_job'
      assert test_endpoint.has_received_information_about_startup
    end
    test_user.purchase
    assert measurement = test_endpoint.has_one_purchase
    assert_equal "purchases", measurement["series"]

    assert_equal "USA", measurement["tags"]["country"]
    assert_equal "KATE-123", measurement["tags"]["terminal"]

    assert_equal 4, measurement["values"]["number_of_products"]
    assert_equal 55.70, measurement["values"]["total_amount"]
    assert_equal 5.70, measurement["values"]["tax"]
  ensure
    test_app.shutdown if test_app
  end

end