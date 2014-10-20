module EhjobAuthentication
  module Api
    class UsersController < ::EhjobAuthentication::ApplicationController
      before_filter :authenticate_api_token

      def associate_user
        if params[:uid].present?
          user = User.find_user_from_oauth(params)
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
        EhjobAuthentication::CreateAssociationUserService.call(params[:user])
      end

      def user_json(user)
        json = {
          email: user.email,
          authentication_token: user.authentication_token,
          highest_role: user.highest_role,
          terminated: user.terminated
        }

        if EhjobAuthentication.config.job?
          json.merge! user.attributes.slice 'first_name', 'last_name'
        else
          json.merge! user.memberships.first.try(:attributes).try(:slice, 'first_name', 'last_name')
        end

        json.to_json
      end
    end
  end
end
