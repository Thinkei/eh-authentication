require 'spec_helper'

def post_assoc_user(params = {})
  default_params = {user: { email: email, password: password }, use_route: :ehjob_authentication}
  params = default_params.merge(params)
  post :associate_user, params
end

describe EhjobAuthentication::API::UsersController do
  describe 'POST #authenticate' do
    let!(:user) { User.create(email: 't@gmail.com', password: 'password') }
    let(:email) {  user.email }
    let(:password) { 'password' }
    let(:api_key) { "Token token=#{Figaro.env.single_authentication_key}" }

    before do
      request.env["devise.mapping"] = Devise.mappings[:user]
    end

    context 'Invalid API key' do
      it 'returns Unauthorized response' do
        request.env["HTTP_AUTHORIZATION"] = 'foo'
        post_assoc_user
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
            post_assoc_user
            expect(response).to be_success
          end

          it 'returns user json, includes highest_role & terminated' do
            post_assoc_user
            json = JSON.parse(response.body)

            expect(json['highest_role']).to eq 'employee'
            expect(json['terminated']).to eq true
          end
        end

        context 'not found' do
          context 'auto create user' do
            let(:additional_params) do
              { auto_create_user: true, user: {email: email, first_name: 'first', last_name: 'last'} }
            end

            context 'email does not exist' do
              let(:email) { 'new_email@gmail.com' }

              it 'creates associate user with given email/first, last name' do
                expect {
                  post_assoc_user(additional_params)
                }.to change(User, :count)

                new_user = User.last
                expect(new_user.first_name).to eq 'first'
                expect(new_user.last_name).to eq 'last'
              end

              it 'returns user json' do
                post_assoc_user(additional_params)
                json = JSON.parse(response.body)
                expect(json['email']).to eq email
                expect(json['authentication_token']).not_to be_nil
                expect(json['highest_role']).not_to be_nil
                expect(json['terminated']).not_to be_nil
                expect(json['first_name']).to eq 'first'
                expect(json['last_name']).to eq 'last'
              end
            end

            context 'email exists' do
              it 'does not create associate user' do
                expect {
                  post_assoc_user(additional_params)
                }.not_to change(User, :count)
              end
            end
          end

          context 'does not auto create user' do
            let(:email) { 'invalid@gmail.com' }

            it 'returns not found' do
              post_assoc_user
              expect(response.status).to eq 404 #not found
            end
          end
        end
      end
    end
  end
end
