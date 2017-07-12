class CreateEntityJob
  include Sidekiq::Worker
  def perform
    Entity.create!(name: Time.current.to_s, state: "parked")
  end
end