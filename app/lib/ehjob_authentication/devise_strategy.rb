module EhjobAuthentication
  class DeviseStrategy < Devise::Strategies::Authenticatable
    def authenticate!
      resource  = valid_password? && mapping.to.find_for_database_authentication(authentication_hash)
      encrypted = false

      local_user = nil

      if validate(resource){ encrypted = true; resource.valid_password?(password) }
        local_user = resource
        local_user.password = password
      end

      raise 'not found' unless local_user
      resource.after_database_authentication
      success!(resource)

    rescue
      if local_user.present?
        resource.after_database_authentication
        success!(resource)
      else
        mapping.to.new.password = password if !encrypted && Devise.paranoid
        fail(:not_found_in_database)
      end
    end
  end
end
