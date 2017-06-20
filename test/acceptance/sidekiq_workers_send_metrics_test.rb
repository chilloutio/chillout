require 'test_helper'
require 'sidekiq'

class SidekiqWorkersSendMetricsTest < AcceptanceTestCase

  def test_sidekiq_worker_sends_metrics
    test_sidekiq_worker = TestSidekiqServer.new
    test_endpoint = TestEndpoint.new(port: 8081)

    test_endpoint.listen
    test_sidekiq_worker.boot(chillout_port: 8081)
    test_sidekiq_worker.push_job

    if ENV['STRATEGY'] != 'active_job'
      assert test_endpoint.has_received_information_about_startup
    end
    assert test_endpoint.has_one_creation_for_entity_resource
  ensure
    test_sidekiq_worker.shutdown if test_sidekiq_worker
  end

end