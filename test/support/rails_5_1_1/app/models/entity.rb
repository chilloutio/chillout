class Entity < ActiveRecord::Base
  state_machine :initial => :parked do
    before_transition :parked => any - :parked, do: :put_on_seatbelt
    after_transition any => :parked do |vehicle, _transition|
      vehicle.seatbelt = 'off'
    end
    around_transition :benchmark

    event :ignite do
      transition :parked => :idling
    end

    event :shift_up do
      transition :idling => :first_gear,
        :first_gear => :second_gear,
        :second_gear => :third_gear
    end

    state :first_gear, :second_gear do
      validates_presence_of :seatbelt_on
    end
  end

  def put_on_seatbelt
    sleep(0.1)
    self.seatbelt = 'on'
  end

  def benchmark
    yield
  end

  def seatbelt_on
    self.seatbelt == 'on'
  end
end