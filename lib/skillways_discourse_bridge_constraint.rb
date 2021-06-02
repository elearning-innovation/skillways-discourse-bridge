class SkillwaysDiscourseBridgeConstraint
  def matches?(request)
    SiteSetting.skillways_discourse_bridge_enabled
  end
end
