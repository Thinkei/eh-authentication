Rails.application.routes.draw do

  mount EhjobAuthentication::Engine => "/ehjob_authentication"
end
