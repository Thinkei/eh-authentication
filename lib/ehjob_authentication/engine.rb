module EhjobAuthentication
  class Engine < ::Rails::Engine
    isolate_namespace EhjobAuthentication
    config.autoload_paths << File.expand_path("../../../app/lib", __FILE__)

    config.after_initialize do
      User.instance_eval do
        include EhjobAuthentication::Roleable
      end
    end
  end
end
