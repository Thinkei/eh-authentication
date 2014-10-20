module EhjobAuthentication
  class CreateAssociationUserService
    def self.call(params)
      user = User.where(email: params[:email]).first_or_create do |user|
        user.first_name = params[:first_name] || 'first_name'
        user.last_name =  params[:last_name] || 'last_name'
        user.password = Devise.friendly_token.first(8)
      end

      user.ensure_authentication_token
      user
    end
  end
end
