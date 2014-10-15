EhjobAuthentication::Engine.routes.draw do
  devise_for :users, skip: [:registrations, :passwords, :sessions]
end
