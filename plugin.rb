# name: skillways-discourse-bridge
# about: A plugin to integrate skillways with discourse.
# version: 0.0.3
# authors: Skillways

enabled_site_setting :skillways_enabled

after_initialize do
  load File.expand_path('../app/controllers/skillways_controller.rb', __FILE__)

  Discourse::Application.routes.append do
    get '/skillways' => 'skillways#index'
  end
end
