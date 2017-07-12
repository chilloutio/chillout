class TransitionsController < ApplicationController
  def create
    e = Entity.new(state: "parked")
    e.ignite
    e.shift_up
    head :ok
  end
end