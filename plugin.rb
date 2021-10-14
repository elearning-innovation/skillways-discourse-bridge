# frozen_string_literal: true

# name: skillways-discourse-bridge
# about: A plugin to integrate skillways with discourse.
# version: 1.2.0
# authors: Skillways

gem 'jwt', '2.3.0'

enabled_site_setting :skillways_discourse_bridge_enabled

PLUGIN_NAME ||= 'SkillwaysDiscourseBridge'

load File.expand_path('lib/skillways-discourse-bridge/engine.rb', __dir__)
