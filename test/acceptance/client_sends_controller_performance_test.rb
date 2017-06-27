require 'test_helper'

class ClientSendsControllerPerformanceTest < AcceptanceTestCase

  def test_client_sends_controller_metrics
    test_app      = TestApp.new
    test_endpoint = TestEndpoint.new(port: 8082)
    test_user     = TestUser.new

    test_endpoint.listen
    test_app.boot(chillout_port: 8082)
    if ENV['STRATEGY'] != 'active_job'
      assert test_endpoint.has_received_information_about_startup
    end
    test_user.create_entity('Myrmecophagidae')
    assert request = test_endpoint.has_one_controller_metric

    assert_equal "request", request["series"]
    assert_equal "EntitiesController", request["tags"]["controller"]
    assert_equal "create", request["tags"]["action"]
    assert_equal "all", request["tags"]["format"]
    assert_equal "POST", request["tags"]["method"]
    assert_equal 302, request["tags"]["status"]

    assert_equal 1, request["values"]["finished"]
    assert_operator 0, :<, request["values"]["duration"]
    assert_operator 0, :<, request["values"]["db"]
    assert_equal 0, request["values"]["view"]
  ensure
    test_app.shutdown if test_app
  end

end
