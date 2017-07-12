require 'state_machine/version'

unless StateMachine::VERSION == '1.2.0'
  # If you see this message, please test removing this file
  # If it's still required, please bump up the version above
  msg = "Please remove me, StateMachine version has changed"
  Rails.logger.warn msg
  raise msg
end

module StateMachine::Integrations::ActiveModel
  public :around_validation
end