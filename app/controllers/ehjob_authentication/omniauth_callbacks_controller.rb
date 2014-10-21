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
      url = UrlExtractorService.call(auth_data, local_user) rescue nil
      redirect_to(url || main_app.new_user_session_path)
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
