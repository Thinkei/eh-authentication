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
    attr_accessor :params, :local_user
    delegate :hr?, :job?, :eh_url, :job_url, to: 'EhjobAuthentication.config'

    def self.call(params, local_user)
      new(params, local_user).call
    end

    def initialize(params, local_user)
      @params = params
      @local_user = local_user
    end

    def call
      raise 'not found' if roles.empty?

      if url = authenticated_url
        raise 'Missing authentication token' unless associate_user.authentication_token
        query = { user_token: associate_user.authentication_token, user_email: associate_user.email }.to_query
        "#{url}?#{query}"
      end
    end

    private

    def authenticated_url
      if roles.include?('employee') || roles.include?('owner/employer')
        if user_terminated?
          if job?
            User.create first_name: 'Test', last_name: 'Test', email: params[:user][:email]
          else
            job_url
          end
        else
          eh_url
        end

      elsif roles == ['job_seeker']
        job_url

      elsif roles == ['hiring_manager']
        "#{job_url}/jobs"
      end
    end

    def roles
      [local_user, associate_user].compact.map(&:highest_role)
    end

    def associate_user
      params.merge!(auto_create_user: auto_create_associate_user?)
      @associate_user ||= (ApiClient.instance.associate_user(params) rescue nil)
    end

    def auto_create_associate_user?
      hr? && local_user.try(:terminated)
    end

    def user_terminated?
      [local_user, associate_user].compact.any?(&:terminated)
    end
  end
end
