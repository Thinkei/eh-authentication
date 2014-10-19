require 'spec_helper'

describe EhjobAuthentication::Api::UsersController do
  describe 'POST #authenticate' do
    let(:email) { 't@gmail.com' }
    let(:password) { 'password' }
    let!(:user) { User.create(email: email, password: password) }
    let(:api_key) { "Token token=#{Figaro.env.single_authentication_key}" }

    before do
      request.env["devise.mapping"] = Devise.mappings[:user]
    end

    context 'Invalid API key' do
      it 'returns Unauthorized response' do
        request.env["HTTP_AUTHORIZATION"] = 'foo'
        post :associate_user, user: { email: email, password: password }, use_route: :ehjob_authentication

        expect(response).to have_http_status(:unauthorized)
      end
    end

    context 'valid API key' do
      before do
        EhjobAuthentication.configure do | config |
          config.eh_url = 'http://www.employmenthero.com'
        end

        User.any_instance.stub(:highest_role).and_return 'employee'
        User.any_instance.stub(:terminated).and_return true
        request.env["HTTP_AUTHORIZATION"] = api_key
      end

      context 'form type' do
        context 'found' do
          it 'returns status success' do
            post :associate_user, user: {email: email, password: password}, :use_route => :ehjob_authentication
            expect(response).to be_success
          end

          it 'returns user json, includes highest_role & terminated' do
            post :associate_user, user: {email: email, password: password}, :use_route => :ehjob_authentication
            json = JSON.parse(response.body)

            expect(json['highest_role']).to eq 'employee'
            expect(json['terminated']).to eq true
          end
        end

        context 'not found' do
          it 'returns not found' do
            post :associate_user, user: {email: 'invalid@gmail.com', password: password}, :use_route => :ehjob_authentication
            expect(response.status).to eq 404 #not found
          end
        end
      end
    end
  end
end
