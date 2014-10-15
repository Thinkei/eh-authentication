Rails.application.routes.draw do
  devise_for :users, controllers: {sessions: 'sessions'}
  mount EhjobAuthentication::Engine => "/ehjob_authentication"
end
