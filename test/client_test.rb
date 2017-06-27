require 'test_helper'

class ClientTest < ChilloutTestCase

  def test_initialize_with_config
    config = Chillout::Config.new("xyz123")
    client = Chillout::Client.new(config)
    assert_equal config, client.config
  end

  def test_initialize_with_options_hash
    client = Chillout::Client.new("xyz123", :platform => 'rack')
    assert_equal "xyz123", client.config.api_key
    assert_equal "rack", client.config.platform
  end

  def test_initialize_with_block
    client = Chillout::Client.new("xyz") do |config|
      config.platform = "rack"
    end
    assert_equal "xyz", client.config.api_key
    assert_equal "rack", client.config.platform
  end

  def test_initialize_with_options_hash_and_block
    client = Chillout::Client.new("xyz", :platform => 'rack') do |config|
      config.port = 443
    end
    assert_equal "xyz", client.config.api_key
    assert_equal "rack", client.config.platform
    assert_equal 443, client.config.port
  end

  def test_initialize_with_unsupported_type_raises_an_error
    assert_raises(ArgumentError) do
      Chillout::Client.new(123)
    end
  end

  def test_enqueues_up_to_5K_metrics
    client = Chillout::Client.new("xyz")
    client.queue.expects(:size).returns(4999)
    client.queue.expects(:<<).returns(nil)
    client.enqueue(Object.new)
  end

  def test_does_not_enqueue_more_than_5K_metrics
    client = Chillout::Client.new("xyz")
    client.queue.expects(:size).returns(5000)
    client.queue.expects(:<<).never
    client.enqueue(Object.new)
  end
end