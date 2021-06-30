module SkillwaysDiscourseBridge
  class Engine < ::Rails::Engine
    engine_name "SkillwaysDiscourseBridge".freeze
    isolate_namespace SkillwaysDiscourseBridge

    config.after_initialize do
      Discourse::Application.routes.append do
        mount ::SkillwaysDiscourseBridge::Engine, at: "/skillways-discourse-bridge"
      end
    end
  end
end
