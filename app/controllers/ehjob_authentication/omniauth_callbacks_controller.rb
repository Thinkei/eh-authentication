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

      if url = UrlExtractorService.call(auth_data, local_user)
        redirect_to url
      else
        provider_name = request.env["omniauth.auth"].provider
        flash[:notice] = t('devise.omniauth_callbacks.success', :kind => t(provider_name, scope: 'devise.providers'))
        sign_in_and_redirect local_user, event: :authentication
      end

    rescue
      redirect_to main_app.new_user_session_path
    end

    def provider_callback_for_signup
      raise NotImplementedError
    end

    alias :facebook :provider_callback
    alias :linkedin :provider_callback
  end
end
