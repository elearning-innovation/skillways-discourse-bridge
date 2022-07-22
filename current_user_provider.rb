class SkillwaysCurrentUserProvider < Auth::DefaultCurrentUserProvider
  def cookie_hash(unhashed_auth_token)
    hash = {
      value: unhashed_auth_token,
    }

    hash
  end
end
