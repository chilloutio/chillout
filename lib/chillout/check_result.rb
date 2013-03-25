class CheckResult
  def initialize(response)
    @response = response
  end

  def successful?
    @response.respond_to?(:code) && @response.code == "200"
  end

  def has_problem_with_authorization?
    @response.respond_to?(:code) && @response.code == "401"
  end
end
