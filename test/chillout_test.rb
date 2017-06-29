require 'test_helper'

class ChilloutModuleTest < ChilloutTestCase
  def test_custom_metrics
    Chillout::Metric.track('RegistrationCompleted')
    assert_equal 1, Chillout.creations['RegistrationCompleted']
  end
end