# name: skillways-discourse-bridge
# about: A plugin to integrate skillways with discourse.
# version: 0.0.5
# authors: Skillways

enabled_site_setting :skillways_discourse_bridge_enabled

after_initialize do
  load File.expand_path('../app/controllers/logout_controller.rb', __FILE__)

  Discourse::Application.routes.append do
    get '/sso-logout' => 'logout#index'
  end
end
