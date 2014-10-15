Devise.setup do |config|
  config.warden do |warden|
    warden.failure_app = EhjobAuthentication::FailureApp
  end
end

Devise.router_name = :ehjob_authentication
