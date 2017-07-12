require 'test_helper'

class ClientSendsStateMachineMetrics < AcceptanceTestCase

  def test_client_sends_state_machine_metrics
    test_app      = TestApp.new
    test_endpoint = TestEndpoint.new(port: 8085)
    test_user     = TestUser.new

    test_endpoint.listen
    test_app.boot(chillout_port: 8085)
    if ENV['STRATEGY'] != 'active_job'
      assert test_endpoint.has_received_information_about_startup
    end
    test_user.transition_entity('Yay')
    assert transition = test_endpoint.has_one_state_machine_metric

    assert_equal "Entity#state", transition["series"]
    assert_equal "Entity", transition["tags"]["class"]
    assert_equal "state", transition["tags"]["attribute"]
    assert_equal "ignite", transition["tags"]["event"]
    assert_equal "parked", transition["tags"]["from"]
    assert_equal "idling", transition["tags"]["to"]

    assert_equal 1, transition["values"]["value"]
    assert_operator 100, :<, transition["values"]["duration"]
    assert_operator 600, :>, transition["values"]["duration"]

    assert transition = test_endpoint.has_one_state_machine_metric

    assert_equal "Entity#state", transition["series"]
    assert_equal "Entity", transition["tags"]["class"]
    assert_equal "state", transition["tags"]["attribute"]
    assert_equal "shift_up", transition["tags"]["event"]
    assert_equal "idling", transition["tags"]["from"]
    assert_equal "first_gear", transition["tags"]["to"]

    assert_equal 1, transition["values"]["value"]
    assert_operator   0, :<, transition["values"]["duration"]
    assert_operator 200, :>, transition["values"]["duration"]
  ensure
    test_app.shutdown if test_app
  end

end
