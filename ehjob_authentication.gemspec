$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "ehjob_authentication/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "ehjob_authentication"
  s.version     = EhjobAuthentication::VERSION
  s.authors     = ["TODO: Your name"]
  s.email       = ["TODO: Your email"]
  s.homepage    = "TODO"
  s.summary     = "TODO: Summary of EhjobAuthentication."
  s.description = "TODO: Description of EhjobAuthentication."

  s.files = Dir["{app,config,db,lib}/**/*"] + ["MIT-LICENSE", "Rakefile", "README.rdoc"]
  s.test_files = Dir["test/**/*"]

  s.add_dependency "rails", "~> 3.2.18"
  # s.add_dependency "jquery-rails"

  s.add_development_dependency "sqlite3"
end
