module EhjobAuthentication
  class Engine < ::Rails::Engine
    isolate_namespace EhjobAuthentication
    config.autoload_paths << File.expand_path("../../../app/lib", __FILE__)
  end
end
