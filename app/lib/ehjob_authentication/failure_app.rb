module EhjobAuthentication
  class FailureApp < Devise::FailureApp
    def redirect_url
      if url = @user_json['url']
        url
      else
        super
      end
    end

    def respond
      @user_json = AuthenticateService.call(params)
      redirect
    end
  end
end
