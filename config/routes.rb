require_dependency "skillways_discourse_bridge_constraint"

SkillwaysDiscourseBridge::Engine.routes.draw do
  get "/" => "skillways_discourse_bridge#index", constraints: SkillwaysDiscourseBridgeConstraint.new
  get "/actions" => "actions#index", constraints: SkillwaysDiscourseBridgeConstraint.new
  get "/actions/:id" => "actions#show", constraints: SkillwaysDiscourseBridgeConstraint.new
end
