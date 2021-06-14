module SkillwaysDiscourseBridge
  class LogoutController < ::ApplicationController
    requires_plugin SkillwaysDiscourseBridge

    skip_before_action :check_xhr # allow non-XHR requests
    skip_before_action :redirect_to_login_if_required # do not require authentication

    def index
      # clear any previously authenticated user
      log_off_user

      # see if the category already exists
      categoryExists = Category.exists?(:name => params[:uniqueCategoryIdentifier])

      # create the category if doesn't exist yet
      unless categoryExists

        # create the new category
        category = Category.new(
          name: params[:uniqueCategoryIdentifier],
          user_id: Discourse::SYSTEM_USER_ID,
        )
        category.save!

        # fetch the template category that we want to copy
        templateCategory = Category.find(params[:templateCategoryId])

        # loop through the template category's topics
        templateCategory.topics.each_with_index do |templateTopic, templateTopicIndex|

          # grab the first post in the template topic
          firstTemplatePostRaw = templateTopic.posts.first().raw

          # update the initially created topic and post on the new category
          if templateTopicIndex === 0

            # update the topic that was automatically created
            firstTopic = category.topics.first()
            firstTopic.title = templateTopic.title
            firstTopic.save!

            # update the post that was automatically created
            firstPost = firstTopic.posts.first()
            firstPost.raw = firstTemplatePostRaw
            firstPost.save!

          # copy the topic and initial post into the new category
          else

            # create the new topic
            topic = Topic.new(
              category: category,
              last_post_user_id: Discourse::SYSTEM_USER_ID,
              title: templateTopic.title,
              user_id: Discourse::SYSTEM_USER_ID,
            )
            topic.save!

            # create the new post
            post = Post.new(
              topic: topic,
              raw: firstTemplatePostRaw,
              user_id: Discourse::SYSTEM_USER_ID,
            )
            post.save!
          end
        end
      end

      # start the SSO process
      redirect_to "/auth/jwt/callback?jwt=#{params[:jwt]}"
    end
  end
end
