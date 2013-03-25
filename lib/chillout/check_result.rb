class CheckResult
  def initialize(response)
    @response = response
  end

  def successful?
    @response.respond_to?(:code) && @response.code == "200"
  end
end
