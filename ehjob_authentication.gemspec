$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "ehjob_authentication/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "ehjob_authentication"
  s.version     = EhjobAuthentication::VERSION
  s.authors     = ["Tien Nguyen", "Tien Le"]
  s.email       = ["nqtien310@gmail.com", "tien@thinkei.com"]
  s.homepage    = "http://www.employmenthero.com"
  s.summary     = "EhjobAuthentication."
  s.description = "Authentication for EH & JOB"

  s.files = Dir["{app,config,db,lib}/**/*"] + ["MIT-LICENSE", "Rakefile", "README.rdoc"]
  s.test_files = Dir["test/**/*"]

  s.add_dependency "httparty"
  s.add_dependency "omniauth"
  s.add_dependency "omniauth-facebook"
  s.add_dependency "omniauth-linkedin-oauth2"
  s.add_development_dependency "debugger"
end
