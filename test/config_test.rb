require 'test_helper'

class ConfigTest < ChilloutTestCase

  def setup
    @config = Chillout::Config.new("xyz123")
  end

  def test_api_key_is_set
    assert_equal "xyz123", @config.api_key
  end

  def test_update_with_options_hash
    @config.update(platform: 'rack')
    assert_equal 'rack', @config.platform
  end

  def test_authentication_user_is_same_as_api_key
    assert_equal @config.api_key, @config.authentication_user
  end

  def test_authentication_password_is_same_as_api_key
    assert_equal @config.api_key, @config.authentication_password
  end

end
