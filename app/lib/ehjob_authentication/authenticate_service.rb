require 'httparty'

module EhjobAuthentication
  class AuthenticateService
    class << self
      def call(user_params)
        HTTParty.post(authenticate_url, body: post_body(user_params))
        service = HTTParty.post(authenticate_url, body: post_body(user_params), headers: post_headers)
      end

      def authenticate_url
        EhjobAuthentication.config.authenticate_url
      end

      def post_body(user_params)
        JSON.generate({
          user: user_params
        })
      end

      def post_headers
        {
          'Content-Type' => 'application/json',
          'Accept' => 'application/json'
        }
      end
    end
  end
end
