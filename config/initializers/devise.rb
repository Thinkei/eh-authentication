Devise.setup do |config|
  config.warden do |manager|
    manager.strategies.add(:ehjob_authentication, EhjobAuthentication::DeviseStrategy)
    manager.default_strategies(:scope => :user).unshift :ehjob_authentication
  end
end
