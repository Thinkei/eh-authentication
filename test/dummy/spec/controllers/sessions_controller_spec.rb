require 'spec_helper'

describe SessionsController do
  describe 'POST #create' do
    let(:email) { 't@gmail.com' }
    let(:password) { 'password' }
    let!(:user) { User.create(email: 't@gmail.com', password: 'password') }

    before do
      request.env["devise.mapping"] = Devise.mappings[:user]
      EhjobAuthentication.configure do |config|
        config.app = 'EH'
        config.base_url = 'http://www.employmenthero.com'
      end
    end

    context 'not found' do
      context 'authentication api' do
        context 'found' do
          before do
            expect(EhjobAuthentication::AuthenticateService).to receive(:call).and_return(user.attributes.merge('url'=> 'http://www.employmenthero.com'))
          end

          it 'returns to service base_url' do
            post :create
            expect(response).to redirect_to 'http://www.employmenthero.com'
          end
        end

        context 'not found' do
          before do
            expect(EhjobAuthentication::AuthenticateService).to receive(:call).and_return({})
          end

          it 'returns to signin path' do
            post :create
            expect(response).to redirect_to '/users/sign_in'
          end
        end
      end
    end
  end
end
