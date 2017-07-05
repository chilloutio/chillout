require 'test_helper'
require 'sidekiq'

class SidekiqWorkersSendMetricsTest < AcceptanceTestCase

  def test_sidekiq_worker_sends_metrics
    test_sidekiq_worker = TestSidekiqServer.new
    test_endpoint = TestEndpoint.new(port: 8081)

    test_endpoint.listen
    test_sidekiq_worker.push_job
    test_sidekiq_worker.boot(chillout_port: 8081)

    if ENV['STRATEGY'] != 'active_job'
      assert test_endpoint.has_received_information_about_startup
    end
    assert test_endpoint.has_one_creation_for_entity_resource

    assert sidekiq = test_endpoint.has_one_sidekiq_metric
    assert_equal "CreateEntityJob", sidekiq.fetch("tags").fetch("class")
    assert_equal "default", sidekiq.fetch("tags").fetch("queue")
    assert_equal "true", sidekiq.fetch("tags").fetch("retriable")
    assert_equal "true", sidekiq.fetch("tags").fetch("success")

    assert sidekiq.fetch("timestamp")

    assert_equal 1, sidekiq.fetch("values").fetch("finished")
    assert_operator 90, :>, sidekiq.fetch("values").fetch("duration")
    assert_operator  0, :<, sidekiq.fetch("values").fetch("duration")
    assert_operator 8000, :>, sidekiq.fetch("values").fetch("delay")
    assert_operator  200, :<, sidekiq.fetch("values").fetch("delay")
  ensure
    if test_sidekiq_worker
      test_sidekiq_worker.clear_jobs
      test_sidekiq_worker.shutdown
    end
  end

end if ENV['SIDEKIQ_SUPPORTED']