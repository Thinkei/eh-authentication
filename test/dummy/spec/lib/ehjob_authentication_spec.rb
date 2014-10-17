describe EhjobAuthentication do
  describe '.config' do
    it 'inits Configs obj' do
      EhjobAuthentication.configure do |config|
        config.eh_url = 'http://www.employmenthero.com'
      end

      config = EhjobAuthentication.config
      expect(config).to be_instance_of(EhjobAuthentication::Config)
      expect(config.eh_url).to eq 'http://www.employmenthero.com'
    end
  end
end
