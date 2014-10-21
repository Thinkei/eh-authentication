module EhjobAuthentication
  class OmniauthCallbacksController < Devise::OmniauthCallbacksController
    def provider_callback
      if request.env['omniauth.origin'].include? 'sign_up'
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
        sign_in(:user, local_user)
        respond_with local_user, location: after_sign_in_path_for(local_user)
      end

    rescue
      redirect_to main_app.new_user_session_path
    end

    def provider_callback_for_signup
      provider_name = request.env["omniauth.auth"].provider
      user = ExternalUserRegistration.call(request.env["omniauth.auth"])
      if user.persisted? || user.save
        sign_in_and_redirect user, :event => :authentication #this will throw if @user is not activated
        flash[:notice] = t('devise.omniauth_callbacks.success', :kind => t(provider_name, scope: 'devise.providers'))
      else
        redirect_to root_path, alert: t('devise.omniauth_callbacks.failure.email')
      end
    end

    alias :facebook :provider_callback
    alias :linkedin :provider_callback
  end
end
