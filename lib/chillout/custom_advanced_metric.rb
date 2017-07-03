module Chillout
  class CustomAdvancedMetric
    def initialize(series:, tags:, timestamp:, values:)
      @series = series
      @tags = tags
      @timestamp = timestamp
      @values = values
    end

    def as_measurements()
      [{
        series: @series,
        tags: @tags,
        timestamp: @timestamp,
        values: @values,
      }]
    end
  end
end