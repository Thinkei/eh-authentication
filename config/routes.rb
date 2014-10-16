EhjobAuthentication::Engine.routes.draw do
  devise_for :users, skip: [:registrations, :passwords, :sessions]
  as :user do
    namespace :api do
      resources :users, only: [] do
        collection do
          post :authenticate
        end
      end
    end
  end
end
