#All roles
#+ EH
#++ owner/employer
#++ employee => both employee & manager

#+ Job
#++ hiring_manager
#++ job_seeker
require 'active_support/concern'

module EhjobAuthentication
  module Roleable
    extend ActiveSupport::Concern

    def highest_role
      if EhjobAuthentication.config.hr?
        role = (employer_or_owner? ? 'owner/employer' : 'employee')
      else
        'job_seeker'
      end
    end

    def terminated
      if EhjobAuthentication.config.hr?
        memberships.any? && memberships.all? { |m| m.termination_date? }
      else
        false
      end
    end

    module ClassMethods
      def find_user_from_oauth(auth)
        Identity.where(uid: auth['uid'], provider: auth['provider']).first.try(:user)
      rescue
        nil
      end
    end
  end
end
