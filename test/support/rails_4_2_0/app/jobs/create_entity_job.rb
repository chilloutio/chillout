class CreateEntityJob
  include Sidekiq::Worker
  def perform
    Entity.create!(name: Time.current.to_s)
  end
end