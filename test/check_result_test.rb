require 'test_helper'

class CheckResultTest < ChilloutTestCase
  def test_successful_for_response_with_200_code
    response = stub(:code => "200")
    check_result = CheckResult.new(response)
    assert check_result.successful?
  end

  def test_not_successful_for_response_with_other_code
    response = stub(:code => "304")
    check_result = CheckResult.new(response)
    refute check_result.successful?
  end

  def test_not_successful_for_response_that_dont_respond_to_code
    response = stub
    check_result = CheckResult.new(response)
    refute check_result.successful?
  end

  def test_dont_have_problem_with_authorization_for_response_with_200_code
    response = stub(:code => "200")
    check_result = CheckResult.new(response)
    refute check_result.has_problem_with_authorization?
  end

  def test_have_problem_with_authorization_for_response_with_401_code
    response = stub(:code => "401")
    check_result = CheckResult.new(response)
    assert check_result.has_problem_with_authorization?
  end

  def test_dont_have_problem_with_authorization_for_response_with_other_code
    response = stub(:code => "501")
    check_result = CheckResult.new(response)
    refute check_result.has_problem_with_authorization?
  end

  def test_dont_have_problem_with_authorization_for_response_that_dont_respond_to_code
    response = stub
    check_result = CheckResult.new(response)
    refute check_result.has_problem_with_authorization?
  end
end
