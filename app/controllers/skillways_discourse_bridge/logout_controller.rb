module SkillwaysDiscourseBridge
  class LogoutController < ::ApplicationController
    include CurrentUser

    requires_plugin SkillwaysDiscourseBridge

    skip_before_action :check_xhr
    skip_before_action :redirect_to_login_if_required

    def index
      log_off_user

      categoryExists = Category.exists?(:name => params[:uniqueCategoryIdentifier])
      unless categoryExists
        category = Category.new(
          name: params[:uniqueCategoryIdentifier],
          user_id: Discourse::SYSTEM_USER_ID,
        )
        category.save!

        templateCategory = Category.find(params[:templateCategoryId])
        templateCategory.topics.each do |topic|
          newTopic = Topic.new(
            category: category,
            title: topic.title,
          )
          newTopic.save!
        end
      end

      redirect_to "/auth/jwt/callback?jwt=#{params[:jwt]}"
    end
  end
end
