require 'test_helper'

class ChilloutModuleTest < ChilloutTestCase
  def setup
    Chillout.creations = nil
  end

  def teardown
    Chillout.creations = nil
  end

  def test_custom_metrics
    Chillout::Metric.track('RegistrationCompleted')
    assert_equal 1, Chillout.creations['RegistrationCompleted']
  end
end