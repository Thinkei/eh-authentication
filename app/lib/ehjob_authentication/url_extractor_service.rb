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
      def call(params, local_user)
        associate_user = ApiClient.instance.associate_user(params)
        roles = [local_user, associate_user].map {|u| u.try(:highest_role)}
        roles = roles.compact
        is_terminated = [local_user, associate_user].compact.any?(&:terminated)
        if roles == []
          raise 'not found'

        elsif roles.include?('employee') || roles.include?('owner/employer')
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

      def call_for_omniauth(params, local_user)
        params.merge(type: 'omniauth')
        call(params, local_user)
      end

      private

      def config
        EhjobAuthentication.config
      end

      def hr?
        config.hr?
      end

      def job?
        config.job?
      end

      def eh_url
        config.eh_url
      end

      def job_url
        config.job_url
      end
    end
  end
end
