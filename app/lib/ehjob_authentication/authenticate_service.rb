require 'httparty'

module EhjobAuthentication
  class AuthenticateService
    class << self
      def call(params)
        validate(params)
        service = HTTParty.post(authenticate_url, body: post_body(user_params), headers: post_headers)
        parse_response(service)
      rescue
        {}
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

      def parse_response(service)
        response = {}

        if service.success?
          response = JSON.parse(service.response.body)
          if response['id'].present? #user exists
            response.merge({'url' => EhjobAuthentication.config.base_url})
          end
        end

        response
      end

      def validate(params)
        raise unless (params['user'].present? &&
           params['user']['email'].present? &&
           params['user']['password'].present?)
      end
    end
  end
end
