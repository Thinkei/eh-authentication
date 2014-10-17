describe EhjobAuthentication::UrlExtractorService do
  subject { EhjobAuthentication::UrlExtractorService }

  let(:local_user) do
    user = User.create(email: 't@gmail.com', password: 'password')
    user.stub(:highest_role).and_return local_highest_role
    user.stub(:terminated?).and_return terminated
    user
  end

  let(:associate_user) do
    OpenStruct.new(
      email: 'nqtien310@gmail.com',
      password: 'password',
      highest_role: assoc_highest_role,
      auth_token: auth_token
    )
  end

  let(:auth_token) { '450928543' }
  let(:local_highest_role) { nil }
  let(:assoc_highest_role) { nil }

  let(:terminated) { false }
  let(:params) { {email: 't@gmail.com', password: 'password'}}

  before do
    expect(EhjobAuthentication::ApiClient.instance).to receive(:associate_user).with(params).and_return associate_user

    EhjobAuthentication.configure do |config|
      config.eh_url = eh_url
      config.job_url = job_url
    end
  end

  let(:eh_url) { nil }
  let(:job_url) { nil }

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
      let(:redirect_url) { "#{job_url}?auth_token=#{auth_token}"}

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
        let(:local_user) { nil }
        let(:assoc_highest_role) { 'hiring_manager' }

        it 'returns job_url/jobs' do
          expect(subject.call(params, local_user)).to eq "#{job_url}/jobs?auth_token=#{auth_token}"
        end
      end
    end

    context 'JOB' do
      let(:eh_url) { 'http://job.employmenthero.com' }
      let(:redirect_url) { "#{eh_url}?auth_token=#{auth_token}"}

      context 'roles include employee' do
        let(:assoc_highest_role) { 'employee' }

        context 'terminated' do
          let(:terminated) { true }

          it 'returns nil' do
            expect(subject.call(params, local_user)).to be_nil
          end
        end

        context 'not terminated' do
          it 'returns EH url' do
            expect(subject.call(params, local_user)).to eq redirect_url
          end
        end
      end

      context 'roles include owner/employer' do
        let(:assoc_highest_role) { 'owner/employer' }

        context 'terminated' do
          let(:terminated) { true }

          it 'returns nil' do
            expect(subject.call(params, local_user)).to be_nil
          end
        end

        context 'not terminated' do
          it 'returns EH url' do
            expect(subject.call(params, local_user)).to eq redirect_url
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
