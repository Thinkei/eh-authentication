describe EhjobAuthentication::UrlExtractorService do
  subject { EhjobAuthentication::UrlExtractorService }

  let(:local_user) do
    user = User.create(email: 't@gmail.com', password: 'password')
    user.stub(:highest_role).and_return local_highest_role
    user.stub(:terminated).and_return terminated
    user.ensure_authentication_token!
    user
  end

  let(:associate_user) do
    OpenStruct.new(
      email: 't@gmail.com',
      password: 'password',
      highest_role: assoc_highest_role,
      authentication_token: authentication_token,
      first_name: 'first',
      last_name: 'last',
      terminated: terminated
    )
  end

  let(:authentication_token) { '450928543' }
  let(:local_highest_role) { nil }
  let(:assoc_highest_role) { nil }
  let(:eh_url) { nil }
  let(:job_url) { nil }
  let(:terminated) { false }
  let(:params) do
    { user: { email: 't@gmail.com', password: 'password'} }
  end

  before do
    expect(EhjobAuthentication::ApiClient.instance).to receive(:associate_user).and_return associate_user

    EhjobAuthentication.configure do |config|
      config.eh_url = eh_url
      config.job_url = job_url
    end
  end

  describe '#call' do
    context 'user not found in both apps' do
      let(:local_user) { nil }
      let(:associate_user) { nil }

      it 'should raise error' do
        expect {
          subject.call(params, local_user)
        }.to raise_error
      end
    end

    context 'EH' do
      let(:job_url) { 'http://job.employmenthero.com' }
      let(:redirect_url) do
        query = { user_token: authentication_token, user_email: associate_user.email }.to_query
        "#{job_url}?#{query}"
      end
      let(:membership) { double(attributes: { 'first_name' => 'Mickey', 'last_name' => 'Mouse' }) }

      before do
        allow(local_user).to receive(:memberships).and_return([membership])
      end

      context 'roles include employee' do
        let(:local_highest_role) { 'employee' }

        context 'terminated' do
          let(:terminated) { true }

          it 'returns job url' do
            expect(subject.call(params, local_user)).to eq redirect_url
          end
        end

        context 'not terminated' do
          it 'returns nil' do
            expect(subject.call(params, local_user)).to be_nil
          end
        end
      end

      context 'roles include owner/employer' do
        let(:local_highest_role) { 'owner/employer' }

        context 'terminated' do
          let(:terminated) { true }

          it 'returns job url' do
            expect(subject.call(params, local_user)).to eq redirect_url
          end
        end

        context 'not terminated' do
          it 'returns nil' do
            expect(subject.call(params, local_user)).to be_nil
          end
        end
      end

      context 'roles eq job_seeker' do
        let(:local_user) { nil }
        let(:assoc_highest_role) { 'job_seeker' }

        it 'returns JOB url' do
          expect(subject.call(params, local_user)).to eq redirect_url
        end
      end

      context 'roles eq hiring_manager' do
        let(:redirect_url) do
          query = { user_token: authentication_token, user_email: associate_user.email }.to_query
          "#{job_url}/jobs?#{query}"
        end

        let(:local_user) { nil }
        let(:assoc_highest_role) { 'hiring_manager' }

        it 'returns job_url/jobs' do
          expect(subject.call(params, local_user)).to eq redirect_url
        end
      end
    end

    context 'JOB' do
      let(:eh_url) { 'http://job.employmenthero.com' }
      let(:redirect_url) do
        query = { user_token: authentication_token, user_email: associate_user.email }.to_query
        "#{eh_url}?#{query}"
      end

      ['employee', 'owner/employer'].each do |role|
        context "roles include #{role}" do
          let(:assoc_highest_role) { role }

          context 'terminated' do
            let(:terminated) { true }
            let(:redirect_url) do
              query = { user_token: local_user.authentication_token, user_email: associate_user.email }.to_query
              "/?#{query}"
            end

            context 'local user not found' do
              let(:local_user) { nil }

              it 'creates local assoc user' do
                expect{
                  subject.call(params, local_user)
                }.to change(User, :count)
              end
            end

            context 'local user is found' do
              it 'does not create local assoc user' do
                local_user

                expect {
                  subject.call(params, local_user)
                }.not_to change(User, :count)
              end
            end

            it 'returns local url with local assoc user auth_token' do
              local_user
              expect(subject.call(params, local_user)).to eq redirect_url
            end
          end

          context 'not terminated' do
            it 'returns EH url' do
              expect(subject.call(params, local_user)).to eq redirect_url
            end
          end
        end
      end

      context 'roles eq job_seeker' do
        let(:local_highest_role) { 'job_seeker' }

        it 'returns nil' do
          expect(subject.call(params, local_user)).to be_nil
        end
      end

      context 'roles eq hiring_manager' do
        let(:local_highest_role) { 'hiring_manager' }

        it 'returns returns nil' do
          expect(subject.call(params, local_user)).to be_nil
        end
      end
    end
  end
end
