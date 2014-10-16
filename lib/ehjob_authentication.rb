require "devise"
require "ehjob_authentication/engine"
require "ehjob_authentication/config"
# EhjobAuthentication.config do |config|
#   config.app = 'EH'
#   config.base_url = 'http://www.employmenthero.com'
# end
#
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
