module Chillout
  module Integrations

    class StateMachineTransitionMeasurement

      def initialize(instance, transition, started, finished)
        @class     = instance.class.name

        @attribute = transition.attribute.to_s
        @event     = transition.event.to_s
        @from      = transition.from.to_s
        @to        = transition.to.to_s

        @started   = started.utc
        @finished  = finished.utc
        @duration = 1000.0 * (@finished.to_f - @started.to_f)
      end

      def job_class
        @class
      end

      def as_measurements()
        [{
          series: "#{@class}##{@attribute}",
          tags: {
            class: @class,
            attribute: @attribute,
            event: @event,
            from: @from,
            to: @to,
          },
          timestamp: @finished.iso8601,
          values: {
            value: 1,
            duration: @duration.to_f,
          },
        }]
      end

    end

    class StateMachine

      def available?
        if defined?(::StateMachine) && defined?(::ActiveRecord)
          require 'state_machine/version'
          Gem::Version.new(StateMachine::VERSION) >= Gem::Version.new('1.1.2')
        end
      rescue
        false
      end

      def enable(client)
        ActiveRecord::Base.subclasses.select do |klass|
          klass.respond_to?(:state_machines)
        end.each do |klass|
          klass.state_machines.each_value do |state_machine|
            state_machine.callbacks[:before].unshift(
              ::StateMachine::Callback.new(:around, &callback(client))
            )
          end
        end
      end

      private

      def callback(client)
        Proc.new do |instance, transition, block|
          started = Time.now.utc
          block.call
          finished = Time.now.utc
          client.enqueue(StateMachineTransitionMeasurement.new(
            instance,
            transition,
            started,
            finished,
          ))
          true
        end
      end

    end

  end
end