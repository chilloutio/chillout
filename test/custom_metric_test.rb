require 'test_helper' 

class CustomMetricTest < ChilloutTestCase
  def setup
    @creations_container = MiniTest::Mock.new
  end

  def test_custom_creation
    @creations_container.expect(:nil?, false, [])
    @creations_container.expect(:increment!, nil, ['foo'])
    @custom_metric = Chillout::CustomMetric.new(@creations_container)
    @custom_metric.track('foo')
    @creations_container.verify
  end
end
