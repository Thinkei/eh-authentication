module EhjobAuthentication
  class OmniauthCallbacksController < Devise::OmniauthCallbacksController
    def provider_callback
      if request.env['omniauth.origin'].to_s.include? 'sign_up'
        provider_callback_for_signup
      else
        provider_callback_for_signin
      end
    end

    private

    def provider_callback_for_signin
      auth_data  = request.env["omniauth.auth"]
      local_user = User.find_user_from_oauth(auth_data)

      url_service = UrlExtractorService.new(auth_data, nil)

      # We need to go to Jobs site to get OAuth user, and then find match user from EH
      # Because EH does not support for OAuth signup,
      # Hence, OAuth details are not stored between two system.
      if EhjobAuthentication.config.hr?
        associate_user = url_service.send(:associate_user)
        local_user ||= User.where(email: associate_user.email).first if associate_user
      end

      url_service.local_user = local_user

      if url = url_service.call
        redirect_to url
      else
        provider_name = request.env["omniauth.auth"].provider
        flash[:notice] = t('devise.omniauth_callbacks.success', :kind => t(provider_name, scope: 'devise.providers'))
        sign_in_and_redirect local_user, event: :authentication
      end

    rescue
      flash[:error] = t('devise.omniauth_callbacks.failed')
      redirect_to main_app.new_user_session_path
    end

    def provider_callback_for_signup
      raise NotImplementedError
    end

    alias :facebook :provider_callback
    alias :linkedin :provider_callback
  end
end
