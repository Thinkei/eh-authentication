require "devise"
require "ehjob_authentication/engine"
require "ehjob_authentication/config"

# JOB CONFIG
# EhjobAuthentication.configure do |config|
#   config.eh_url = 'http://www.employmenthero.com'
# end

# EH CONFIG
# EhjobAuthentication.configure do |config|
#   config.job_url = 'http://job.employmenthero.com'
# end

module EhjobAuthentication
  mattr_accessor :config

  def self.configure
    @@config ||= Config.new
    yield @@config
  end

  def self.config
    raise 'Adds EhjobAuthentication.config in initializers' if @@config.nil?
    @@config
  end
end
