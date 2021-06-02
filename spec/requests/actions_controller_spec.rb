require 'rails_helper'

describe skillways-discourse-bridge::ActionsController do
  before do
    Jobs.run_immediately!
  end

  it 'can list' do
    sign_in(Fabricate(:user))
    get "/skillways-discourse-bridge/list.json"
    expect(response.status).to eq(200)
  end
end
