#All roles
#+ EH
#++ owner/employer
#++ employee => both employee & manager

#+ Job
#++ hiring_manager
#++ job_seeker

module EhjobAuthentication
  module Roleable
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
        nil
      end
    end
  end
end
