require 'jwt'

module SkillwaysDiscourseBridge
  class LogoutController < ::ApplicationController
    requires_plugin SkillwaysDiscourseBridge

    skip_before_action :check_xhr # allow non-XHR requests
    skip_before_action :redirect_to_login_if_required # do not require authentication

    def index
      jwt = params[:jwt]

      decodedJwt = JWT.decode(
        jwt,
        SiteSetting.skillways_discourse_bridge_jwt_secret,
        true
      )[0]

      jwtType = decodedJwt['data']['type']
      if jwtType === 'access'
        email = decodedJwt['data']['user']['email']
        nameFull = decodedJwt['data']['user']['firstName'] + ' ' + decodedJwt['data']['user']['lastName']
      elsif jwtType === 'lti-access'
        email = decodedJwt['data']['ltiUser']['email']
        nameFull = decodedJwt['data']['ltiUser']['nameFull']
      end

      userExists = User.with_email(email).count >= 1

      if !userExists
        user = User.new(
          active: true,
          approved: true,
          email: email,
          name: nameFull,
          password: SecureRandom.hex,
          username: UserNameSuggester.suggest(nameFull),
        )
        user.save!
      else
        user = User.with_email(email)[0]
        user.name = nameFull
        user.save!
      end

      # see if the category already exists
      categoryExists = Category.exists?(:name => params[:uniqueCategoryIdentifier])

      # fetch the template category that we want to copy
      templateCategory = Category.find(params[:templateCategoryId])

      category = nil
      if categoryExists
        category = Category.where(name: params[:uniqueCategoryIdentifier])[0]

        # loop through the template category's topics
        templateCategory.topics.each_with_index do |templateTopic, templateTopicIndex|
          # update the topic
          topic = category.topics[templateTopicIndex]
          topic.title = templateTopic.title
          topic.save!

          # update the initial post in the topic
          templatePostRaw = templateTopic.posts.first().raw
          post = topic.posts.first()
          post.raw = templatePostRaw
          post.save!
        end
      end

      # create the category if doesn't exist yet
      unless categoryExists

        # create the new category
        category = Category.new(
          name: params[:uniqueCategoryIdentifier],
          user_id: Discourse::SYSTEM_USER_ID,
        )
        category.save!

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

      log_on_user user

      if (category.topics.count === 1)
        redirect_to "/t/#{category.topics.first().id}"
      else
        redirect_to "/c/#{params[:uniqueCategoryIdentifier]}"
      end

      # how to output some debug data
      # render :json => {
      #   decodedJwt: decodedJwt,
      # }
    end
  end
end
