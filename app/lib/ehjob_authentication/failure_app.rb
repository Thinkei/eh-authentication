module EhjobAuthentication
  class FailureApp < Devise::FailureApp
    def respond
      redirect
    end
  end
end
