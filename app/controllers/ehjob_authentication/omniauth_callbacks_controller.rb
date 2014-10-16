module EhjobAuthentication
  class OmniauthCallbacksController < Devise::OmniauthCallbacksController
    def provider_callback
      auth_data = request.env["omniauth.auth"]

      if auth_data.info.email.present?
        associated_user = ApiClient.instance.associate_user(email: auth_data.info.email)
      end

      user = local_user_from_oauth(auth_data)
      url  = RedirectUrlService(user) || new_user_session_path

      redirect_to url
    end

    alias :facebook :provider_callback
    alias :linkedin :provider_callback

    private

    def local_user_from_oauth(auth)
      return unless Object.const_defined?('Identity')

      Indentity.where(uid: auth.uid, provider: auth.provider).first.try(:user)
    end
  end
end
