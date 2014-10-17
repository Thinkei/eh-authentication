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

      if roles.include?('employee') || roles.include?('owner/employer')
        if user_terminated?
          if hr?
            job_url
          else
            user = User.create(first_name: 'Test', last_name: 'Test', email: params[:user][:email])
            job_url # with token from user
          end
        else
          eh_url if job?
        end

      elsif roles == ['job_seeker']
        job_url if hr?

      elsif roles == ['hiring_manager']
        "#{job_url}/jobs" if hr?
      end
    end

    private

    def roles
      [local_user, associate_user].compact.map(&:highest_role)
    end

    def associate_user
      ApiClient.instance.associate_user(params.merge(auto_create_user: auto_create_associate_user))
    end

    def auto_create_associate_user
      hr? && local_user.terminated?
    end

    def user_terminated?
      [local_user, associate_user].compact.any?(&:terminated)
    end
  end
end
