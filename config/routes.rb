EhjobAuthentication::Engine.routes.draw do
  devise_for :users, skip: [:registrations, :passwords, :sessions] do
    get 'users/sign_in' => 'sessions#new', as: :new_user_session
  end
end
