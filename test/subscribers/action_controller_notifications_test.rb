require 'test_helper'
require 'active_job'
require 'active_job/test_helper'

module Chillout
  module Subscribers
    class ActionControllerNotificationsTest < ChilloutTestCase
      include ActiveJob::TestHelper

      def test_as_measurements
        time = Time.utc(2017, 6, 27, 10, 26, 33)
        metric = ActionControllerNotifications::RequestMetric.new(
          ActiveSupport::Notifications::Event.new(
            "asd", time, time+1, "uniq", {
            controller: "PostsController",
            action: "index",
            params: {"action" => "index", "controller" => "posts"},
            headers: nil, #ActionDispatch::Http::Headers.new,
            format: :html,
            method: "GET",
            path: "/posts",
            status: 200,
            view_runtime: 46.848,
            db_runtime: 0.157
          }
        ))

        assert_equal [{
          timestamp: "2017-06-27T10:26:34Z",
          series: "request",
          tags: {
            controller: "PostsController",
            action: "index",
            format: "html",
            method: "GET",
            status: 200,
          },
          values: {
            finished: 1,
            duration: 1000.000,
            db:          0.157,
            view:       46.848,
          },
        }], metric.as_measurements
      end

      def test_measurements_are_floats
        time = Time.utc(2017, 6, 27, 10, 26, 33)
        metric = ActionControllerNotifications::RequestMetric.new(
          ActiveSupport::Notifications::Event.new(
            "asd", time, time, "uniq", {
            controller: "PostsController",
            action: "index",
            params: {"action" => "index", "controller" => "posts"},
            headers: nil, #ActionDispatch::Http::Headers.new,
            format: :html,
            method: "GET",
            path: "/posts",
            status: 200,
            view_runtime: 46,
            db_runtime: 1,
          }
        ))
        values = metric.as_measurements[0].fetch(:values)
        assert  0.0.eql? values.fetch(:duration)
        assert  1.0.eql? values.fetch(:db)
        assert 46.0.eql? values.fetch(:view)
      end
    end
  end
end