require 'test_helper'
require 'chillout/custom_advanced_metric'

module Chillout
  class CustomAdvancedMetricTest < ChilloutTestCase
    def setup
      @time = Time.now.utc
    end

    def test_basic_scenario
      m = CustomAdvancedMetric.new(
        series: "who",
        tags: {
          let: "the_dog",
        },
        values: {
          out: 1,
          we: "did",
        },
        timestamp: @time
      ).as_measurements

      assert_equal m, [{
        series: "who",
        tags: {
          let: "the_dog",
        },
        values: {
          out: 1,
          we: "did",
        },
        timestamp: @time,
      }]
    end

    def test_tags
      m = CustomAdvancedMetric.new(
        series: "who",
        tags: [["1", "two"]],
        values: {},
        timestamp: @time
      ).as_measurements

      assert_equal m.first.fetch(:tags), {"1" => "two"}
    end

    def test_values
      m = CustomAdvancedMetric.new(
        series: "who",
        tags: [],
        values: [[:dog, 3]],
        timestamp: @time
      ).as_measurements

      assert_equal m.first.fetch(:values), {dog: 3}
    end

    def test_invalid_series
      assert_raises ArgumentError do
        CustomAdvancedMetric.new(
          series: Object.new,
          tags: {
            let: "the_dog",
          },
          values: {
            out: 1,
            we: "did",
          },
          timestamp: @time
        )
      end
    end

    def test_invalid_series
      assert_raises NoMethodError do
        CustomAdvancedMetric.new(
          series: Object.new,
          tags: {
            let: "the_dog",
          },
          values: {
            out: 1,
            we: "did",
          },
          timestamp: @time
        )
      end
    end

  end
end