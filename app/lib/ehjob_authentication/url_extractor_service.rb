# params {
#   user: {
#     email: email,
#     password: password,
#   },
#   type: type
# }

# call#result {
#   redirect_url => 'redirect to that url'
#   nil => 'login successfully'
#   raise => 'login fail'
# }

module EhjobAuthentication
  class UrlExtractorService
    class << self
      delegate :hr?, :job?, :eh_url, :job_url, to: 'EhjobAuthentication.config'

      def call(params, local_user)
        associate_user = ApiClient.instance.associate_user(params)
        roles = [local_user, associate_user].compact.map(&:highest_role)
        is_terminated = [local_user, associate_user].compact.any?(&:terminated)

        raise 'not found' if roles.empty?

        if roles.include?('employee') || roles.include?('owner/employer')
          if is_terminated
            #TODO create job seeker on job
            job_url if hr?
          else
            eh_url if job?
          end

        elsif roles == ['job_seeker']
          job_url if hr?

        elsif roles == ['hiring_manager']
          "#{job_url}/jobs" if hr?
        end
      end
    end
  end
end
