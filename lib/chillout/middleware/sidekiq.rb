module Chillout
  module Middleware

    class SidekiqJobMeasurement
      attr_reader :retriable, :queue, :started,
        :finished, :delay, :duration, :success

      def initialize(job, queue, started, finished, success)
        @class     = job["class"].to_s
        @retriable = job["retry"].to_s
        @queue     = queue
        @started   = started.utc
        @finished  = finished.utc
        enqueued_at = job["enqueued_at"] || @finished.to_f
        @delay = 1000.0 * (@finished.to_f - enqueued_at)
        @duration = 1000.0 * (@finished.to_f - @started.to_f)
        @success = success.to_s
      end

      def job_class
        @class
      end

      def as_measurements()
        [{
          series: "sidekiq_jobs",
          tags: {
            class: @class,
            retriable: @retriable,
            queue: @queue,
            success: @success.to_s,
          },
          timestamp: @finished.iso8601,
          values: {
            finished: 1,
            duration: @duration.to_f,
            delay: @delay.to_f
          },
        }]
      end
    end

    class SidekiqCreationsMonitor
      def initialize(options)
        @client = options.fetch(:client)
      end

      def call(_worker, job, queue)
        started = Time.now.utc
        success = false
        yield
        success = true
      ensure
        enqueue(queue, job, started, success)
      end

      def enqueue(_queue, job, started, success)
        finished = Time.now.utc
        if creations = Chillout.creations
          Chillout.creations = nil
          @client.enqueue(creations)
        end
        @client.enqueue(SidekiqJobMeasurement.new(
          job,
          _queue,
          started,
          finished,
          success
        ))
      end
    end

  end
end