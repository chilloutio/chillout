Rails400::Application.routes.draw do
  resources :entities
  resources :purchases, only: %i(create)
  resources :transitions, only: %i(create)
end
