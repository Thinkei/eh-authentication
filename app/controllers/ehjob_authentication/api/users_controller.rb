module EhjobAuthentication
  module Api
    class UsersController < ::EhjobAuthentication::ApplicationController
      def authenticate
        user = User.where(email: params[:user][:email]).last
        if user && user.valid_password?(params[:user][:password])
          render status: :ok, json: user.to_json
        else
          render status: :not_found, nothing: true
        end
      end
    end
  end
end
