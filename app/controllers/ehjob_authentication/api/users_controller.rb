module EhjobAuthentication
  module API
    class UsersController < ::EhjobAuthentication::ApplicationController
      before_filter :authenticate_api_token

      def associate_user
        if omniauth_params?
          user = User.where(email: params[:info][:email]).last
        else
          user = User.where(email: params[:user][:email]).last
          user = (user && user.valid_password?(params[:user][:password])) ? user : nil
        end

        user ||= create_user if params[:auto_create_user]

        if user
          render status: :ok, json: user_json(user)
        else
          render status: :not_found, nothing: true
        end
      end

      private

      def authenticate_api_token
        authenticate_or_request_with_http_token do |token, options|
          token == Figaro.env.single_authentication_key
        end
      end

      def create_user
        if omniauth_params?
          EhjobAuthentication::CreateAssociationUserService.call(params[:info])
        else
          EhjobAuthentication::CreateAssociationUserService.call(params[:user])
        end
      end

      def user_json(user)
        json = {
          email: user.email,
          authentication_token: user.authentication_token,
          highest_role: user.highest_role,
          encrypted_password: user.encrypted_password,
          terminated: user.terminated
        }

        if EhjobAuthentication.config.job?
          json.merge! user.attributes.slice 'first_name', 'last_name'
        else
          json.merge!(user.memberships.first.try(:attributes).try(:slice, 'first_name', 'last_name') || {})
        end

        json.to_json
      end

      def omniauth_params?
        params[:uid].present?
      end
    end
  end
end
