class SkillwaysCurrentUserProvider < Auth::DefaultCurrentUserProvider
  def cookie_hash(unhashed_auth_token)
    exit
    hash = {
      value: unhashed_auth_token,
      httponly: true,
      secure: SiteSetting.force_https,
      domain: :all
    }

    if SiteSetting.persistent_sessions
      hash[:expires] = SiteSetting.maximum_session_age.hours.from_now
    end

    if SiteSetting.same_site_cookies != "Disabled"
      hash[:same_site] = SiteSetting.same_site_cookies
    end

    hash
  end
end
