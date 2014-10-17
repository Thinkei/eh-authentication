require 'spec_helper'

describe SessionsController do
  describe 'POST #create' do
    let(:email) { 't@gmail.com' }
    let(:password) { 'password' }
    let!(:user) { User.create(email: 't@gmail.com', password: 'password') }
    let(:params) do
      { user: {email: email, password: 'password'} }
    end

    let(:email) { user.email }

    before do
      request.env["devise.mapping"] = Devise.mappings[:user]
      EhjobAuthentication.configure do |config|
        config.eh_url = 'http://www.employmenthero.com'
      end
    end

    context 'UrlExtractorService raise errors' do
      before do
        expect(EhjobAuthentication::UrlExtractorService).to receive(:call).and_raise
      end

      context 'local user is found' do
        it 'logins successfully & redirects to after_sign_in_path' do
          post :create, params
          expect(controller.resource).not_to be_nil
          expect(response).to redirect_to '/after_sign_in_path'
        end
      end

      context 'local user is not found' do
        let(:email) {'invalid@gmail.com'}

        it 'fail to login' do
          post :create, params
          expect(controller.resource).to be_nil
        end
      end
    end

    context 'UrlExtractorService returns nil' do
      before do
        expect(EhjobAuthentication::UrlExtractorService).to receive(:call).and_return nil
      end

      it 'logins successfully & redirects to after_sign_in_path' do
        post :create, params
        expect(controller.resource).not_to be_nil
        expect(response).to redirect_to '/after_sign_in_path'
      end
    end

    context 'UrlExtractorService returns url' do
      before do
        expect(EhjobAuthentication::UrlExtractorService).to receive(:call).and_return 'http://www.employmenthero.com'
      end

      it 'redirect to redirect_url' do
        post :create, params
        expect(response).to redirect_to 'http://www.employmenthero.com'
      end
    end
  end
end
