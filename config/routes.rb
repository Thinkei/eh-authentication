EhjobAuthentication::Engine.routes.draw do
  devise_for :users, skip: [:registrations, :passwords, :sessions, :omniauth_callbacks]
  as :user do
    namespace :api do
      resources :users, only: [] do
        collection do
          post :authenticate
          post :associate_user
        end
      end
    end
  end
end
