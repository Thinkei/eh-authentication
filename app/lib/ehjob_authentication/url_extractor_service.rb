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

        #for now, only EH's users might be terminated
        is_terminated = [local_user, associate_user].compact.any?(&:terminated)

        redirect_url = if roles == []
          raise 'not found'

        elsif roles.include?('employee') || roles.include?('owner/employer')
          if is_terminated
            job_url
          else
            eh_url
          end

        elsif roles == ['job_seeker']
          job_url

        elsif roles == ['hiring_manager']
          "#{job_url}/jobs" if hr?
        end

        if redirect_url
          raise 'missing authentication token' if associate_user.auth_token.nil?
          "#{redirect_url}?auth_token=#{associate_user.auth_token}"
        else
          nil
        end
      end
    end
  end
end
