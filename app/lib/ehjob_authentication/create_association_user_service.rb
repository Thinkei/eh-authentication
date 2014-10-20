module EhjobAuthentication
  class CreateAssociationUserService
    def self.call(params)
      user = User.where(email: params[:email]).last

      if !user
        user = User.create(
          email:      params[:email],
          first_name: params[:first_name] || 'first_name',
          last_name:  params[:last_name]  || 'last_name',
          password:   params[:password]   || Devise.friendly_token.first(8)
        )

        if params[:encrypted_password]
          user.update_attribute :encrypted_password, params[:encrypted_password]
        end
      end
      user.ensure_authentication_token!
      user
    end
  end
end
