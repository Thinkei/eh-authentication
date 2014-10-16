module EhjobAuthentication
  class Config
    attr_accessor :app, :base_url

    def authenticate_url
      raise "'base_url' isn't set yet" if base_url.nil?
      "#{base_url}/api/users/authenticate"
    end

    def hr?
      app == :hr
    end
  end
end
