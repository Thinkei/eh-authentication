module EhjobAuthentication
  module Api
    class UsersController < ::EhjobAuthentication::ApplicationController
      before_filter :authenticate_api_token

      def associate_user
        if params[:type] == 'omniauth'
          user = User.where(email: params[:email], auth_token: params[:user][:auth_token]).first
        else
          user = User.where(email: params[:user][:email]).last
          user = user.valid_password?(params[:user][:password]) ? user : nil
        end

        if user
          render status: :ok, json: { highest_role: user.highest_role, terminated: user.terminated }.to_json
        else
          render status: :not_found, nothing: true
        end
      end

      def authenticate_api_token
        authenticate_or_request_with_http_token do |token, options|
          token == Figaro.env.single_authentication_key
        end
      end
    end
  end
end
