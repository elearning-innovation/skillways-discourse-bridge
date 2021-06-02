# frozen_string_literal: true

# name: skillways-discourse-bridge
# about: A plugin to integrate skillways with discourse.
# version: 0.0.5
# authors: Skillways

register_asset 'stylesheets/common/skillways-discourse-bridge.scss'
register_asset 'stylesheets/desktop/skillways-discourse-bridge.scss', :desktop
register_asset 'stylesheets/mobile/skillways-discourse-bridge.scss', :mobile

enabled_site_setting :skillways_discourse_bridge_enabled

PLUGIN_NAME ||= 'SkillwaysDiscourseBridge'

load File.expand_path('lib/skillways-discourse-bridge/engine.rb', __dir__)

after_initialize do
  load File.expand_path('../app/controllers/logout_controller.rb', __FILE__)

  Discourse::Application.routes.append do
    get '/sso-logout' => 'logout#index'
  end
end
