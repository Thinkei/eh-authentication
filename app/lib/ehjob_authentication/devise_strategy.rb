module EhjobAuthentication
  class DeviseStrategy < Devise::Strategies::Authenticatable
    def authenticate!
      resource  = valid_password? && mapping.to.find_for_database_authentication(authentication_hash)
      encrypted = false

      local_user = nil

      if validate(resource){ encrypted = true; resource.valid_password?(password) }
        local_user = resource
      end

      associated_user = AuthenticateService.call(resource.email, password)
      roles = [local_user.role, associated_user['role']]

      if roles.all?(&:nil?)
        mapping.to.new.password = password if !encrypted && Devise.paranoid
        fail(:not_found_in_database)

      elsif redirectUrl = UrlExtractorService.call(roles)
        redirect! redirectUrl

      else
        success!(resource)
      end
    end
  end
end
