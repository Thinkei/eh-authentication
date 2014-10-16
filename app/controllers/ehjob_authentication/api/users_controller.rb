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

      def associate_user
        if user = User.where(email: params[:email]).first
          render status: :ok, json: user_json(user)
        else
          render status: :not_found, nothing: true
        end
      end

      private

      def user_json(user)
        if EhjobAuthentication.config.hr?
          terminated = user.memberships.any? && user.memberships.all? { |m| m.termination_date? }
          role = (user.employer_or_owner? ? 'owner/employer' : 'employee')
        else
          # FIXME: Temporary return 'job_seeker' role as EH Jobs has not implemented role-based system
          role = 'job_seeker'
        end

        { role: role, terminated: terminated }.to_json
      end

    end
  end
end
