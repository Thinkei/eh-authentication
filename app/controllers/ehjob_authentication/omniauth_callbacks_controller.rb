module EhjobAuthentication
  class OmniauthCallbacksController < Devise::OmniauthCallbacksController
    def provider_callback
      auth_data  = request.env["omniauth.auth"]
      local_user = User.find_user_from_oauth(auth_data)
      url = UrlExtractorService.call(auth_data, local_user) rescue nil

      redirect_to(url || main_app.new_user_session_path)
    end

    alias :facebook :provider_callback
    alias :linkedin :provider_callback
  end
end
