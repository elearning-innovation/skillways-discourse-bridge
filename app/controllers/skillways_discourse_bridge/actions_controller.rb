module SkillwaysDiscourseBridge
  class ActionsController < ::ApplicationController
    requires_plugin SkillwaysDiscourseBridge

    before_action :ensure_logged_in

    def index
      templateCategoryId = params[:templateCategoryId]
      uniqueCategoryIdentifier = params[:uniqueCategoryIdentifier]

      categoryExists = Category.exists?(:name => uniqueCategoryIdentifier)
      if categoryExists
        category = Category.where(:name => uniqueCategoryIdentifier)
      else
        category = Category.new(:name => uniqueCategoryIdentifier)
        # copy topics
      end

      # check the number of topics in the category
      # if the category has multiple topics then redirect to the category
      # if the category has one topic then redirect to the topic
      render_json_dump({ actions: [] })
    end

    def show
      render_json_dump({ action: { id: params[:id] } })
    end
  end
end
