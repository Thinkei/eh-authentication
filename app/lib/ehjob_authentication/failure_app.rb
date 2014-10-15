module EhjobAuthentication
  class FailureApp < Devise::FailureApp
    def redirect_url
      if @user_json.present?
        EhjobAuthentication.config.base_url
      else
        super
      end
    end

    def respond
      @user_json = AuthenticateService.call(params['user'])
      redirect
    end
  end
end
