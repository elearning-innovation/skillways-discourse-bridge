module SkillwaysDiscourseBridge
  class LogoutController < ::ApplicationController
    include CurrentUser

    requires_plugin SkillwaysDiscourseBridge

    skip_before_action :check_xhr
    skip_before_action :redirect_to_login_if_required

    def index
      log_off_user
      redirect_to "/auth/jwt/callback?jwt=#{params[:jwt]}"
    end
  end
end
