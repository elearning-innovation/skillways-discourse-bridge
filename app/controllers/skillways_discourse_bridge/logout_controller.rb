require 'jwt'

class Auth::DefaultCurrentUserProvider
  def set_auth_cookie!(unhashed_auth_token, user, cookie_jar)
    data = {
      token: unhashed_auth_token,
      user_id: user.id,
      trust_level: user.trust_level,
      issued_at: Time.zone.now.to_i
    }

    if SiteSetting.persistent_sessions
      expires = SiteSetting.maximum_session_age.hours.from_now
    end

    if SiteSetting.same_site_cookies != "Disabled"
      same_site = SiteSetting.same_site_cookies
    end

    cookie_jar.encrypted[TOKEN_COOKIE] = {
      value: data,
      httponly: true,
      secure: SiteSetting.force_https,
      expires: expires,
      same_site: same_site,
      domain: :all
    }
  end
end

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
        email = decodedJwt['data']['user']['email'].downcase
        nameFull = decodedJwt['data']['user']['firstName'] + ' ' + decodedJwt['data']['user']['lastName']
      elsif jwtType === 'lti-access'
        email = decodedJwt['data']['ltiUser']['email'].downcase
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
        user.email = email
        user.name = nameFull
        user.save!
      end

      # see if the category already exists
      categoryExists = Category.exists?(:name => params[:uniqueCategoryIdentifier])

      # fetch the template category that we want to copy
      templateCategory = Category.find(params[:templateCategoryId])

      # fetch or create the category as needed
      category = nil
      if categoryExists
        category = Category.where(name: params[:uniqueCategoryIdentifier])[0]
      else
        category = Category.new(
          name: params[:uniqueCategoryIdentifier],
          user_id: Discourse::SYSTEM_USER_ID,
        )
        category.save!
      end

      if !templateCategory.nil? && !category.nil?
        # loop through the template category's topics
        sortedTemplateTopics = templateCategory.topics.sort_by { |topic| topic.id }
        sortedTemplateTopics.each_with_index do |templateTopic, templateTopicIndex|
          # grab the first post in the template topic
          firstTemplatePostRaw = templateTopic.posts.first().raw

          if templateTopicIndex === 0
            # update the topic that was automatically created
            firstTopic = category.topics.first()
            firstTopic.title = templateTopic.title
            firstTopic.save!

            # update the post that was automatically created
            firstPost = firstTopic.posts.first()
            firstPost.raw = firstTemplatePostRaw
            firstPost.save!
          else
            topic = nil

            sortedTopics = category.topics.sort_by { |topic| topic.id }
            if sortedTopics[templateTopicIndex].nil?
              # create the topic
              topic = Topic.new(
                category: category,
                last_post_user_id: Discourse::SYSTEM_USER_ID,
                title: templateTopic.title,
                user_id: Discourse::SYSTEM_USER_ID,
              )
              topic.save!
            else
              # update the topic
              topic = sortedTopics[templateTopicIndex]
              topic.title = templateTopic.title
              topic.save!
            end

            if !topic.nil?
              # sort all posts
              sortedPosts = topic.posts.sort_by { |post| post.post_number }
              sortedTemplatePosts = templateTopic.posts.sort_by { |post| post.post_number }

              sortedTemplatePosts.each_with_index do |templatePost, templatePostIndex|
                if sortedPosts[templatePostIndex].nil?
                  # create the post
                  post = Post.new(
                    raw: templatePost.raw,
                    topic: topic,
                    user_id: Discourse::SYSTEM_USER_ID,
                  )
                  post.save!
                else
                  # update the post
                  post = sortedPosts[templatePostIndex]
                  post.raw = templatePost.raw
                  post.topic = topic
                  post.save!
                end
              end
            end
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
      #   debugData: debugData,
      # }
    end
  end
end
