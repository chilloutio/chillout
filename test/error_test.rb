require 'test_helper'

class ErrorTest < ChilloutTestCase

  def setup
    @exception = build_exception(ArgumentError)
    @env = { 'charset' => 'utf-8' }
    @error = Chillout::Error.new(@exception, @env)
  end

  def test_exception_class
    assert_equal "ArgumentError", @error.exception_class
  end

  def test_backtrace
    assert_kind_of Array, @error.backtrace
  end

  def test_file
    file = File.expand_path('../test_helper.rb', __FILE__)
    assert_equal file, @error.file
  end

  context "controller is not given" do

    def test_controller_name
      assert_nil @error.controller_name
    end

    def test_controller_action
      assert_nil @error.controller_action
    end

  end

  context "controller is given" do

    setup do
      @controller = mock("controller")
      @env['action_controller.instance'] = @controller
    end

    def test_controller_action_when_controller_is_set
      @controller.expects(:action_name).returns("index")
      assert_equal "index", @error.controller_action
    end

    def test_controller_name_when_controller_is_set
      @controller.expects(:controller_name).returns("ApplicationController")
      assert_equal "ApplicationController", @error.controller_name
    end

  end

  context "current user is not given" do

    def test_current_user_id
      assert_nil @error.current_user_id
    end

    def test_current_user_email
      assert_nil @error.current_user_email
    end

    def test_current_user_full_name
      assert_nil @error.current_user_full_name
    end

  end

  context "current user is given" do

    setup do
      @user = mock("user")
      @env['current_user'] = @user
    end

    def test_current_user_id
      @user.expects(:id).returns(123)
      assert_equal 123, @error.current_user_id
    end

    def test_current_user_email
      @user.expects(:email).returns("john@example.net")
      assert_equal "john@example.net", @error.current_user_email
    end

    def test_current_user_full_name
      @user.expects(:full_name).returns("john doe")
      assert_equal "john doe", @error.current_user_full_name
    end
  end

  context "current user is given but does not respond to expected methods" do

    setup do
      @user = mock("user")
      @env['current_user'] = @user
    end

    def test_current_user_id
      assert_nil @error.current_user_id
    end

    def test_current_user_email
      assert_nil @error.current_user_email
    end

    def test_current_user_full_name
      assert_nil @error.current_user_full_name
    end

  end

end
