require_dependency "skillways_discourse_bridge_constraint"

SkillwaysDiscourseBridge::Engine.routes.draw do
  get "/" => "skillways_discourse_bridge#index", constraints: SkillwaysDiscourseBridgeConstraint.new
  get "/sso-logout" => "logout#index", constraints: SkillwaysDiscourseBridgeConstraint.new
end
