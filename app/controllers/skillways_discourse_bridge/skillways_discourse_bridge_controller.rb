module SkillwaysDiscourseBridge
  class SkillwaysDiscourseBridgeController < ::ApplicationController
    requires_plugin SkillwaysDiscourseBridge

    before_action :ensure_logged_in

    def index
    end
  end
end
