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

        user ||= create_user if params[:auto_create_user] # TODO: Convert to boolean?

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
          User.where(email: params[:user][:email]).first_or_create do |user|
            # TODO pass correct name, password parameters
            user.first_name = 'Test'
            user.last_name = 'Test'
            user.password = 'Password'
          end
      end

      def user_json(user)
        {
          email: user.email,
          authentication_token: user.authentication_token,
          highest_role: user.highest_role,
          terminated: user.terminated
        }.to_json
      end
    end
  end
end
