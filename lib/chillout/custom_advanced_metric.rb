module Chillout
  class CustomAdvancedMetric

    def initialize(series:, tags:, timestamp:, values:)
      @series = series.to_str
      @tags = tags.to_h
      @timestamp = timestamp.utc
      @values = values.to_h
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