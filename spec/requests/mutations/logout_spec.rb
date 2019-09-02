require 'rails_helper'

RSpec.describe 'Logout Requests' do
  include_context 'with graphql query request'

  let(:user) { create(:user, :confirmed) }
  let(:query) do
    <<-GRAPHQL
      mutation {
        userLogout {
          authenticable { email }
        }
      }
    GRAPHQL
  end

  before { post_request }

  context 'when user is logged in' do
    let(:headers) { user.create_new_auth_token }

    it 'logs out the user' do
      expect(response).not_to include_auth_headers
      expect(user.reload.tokens.keys).to be_empty
      expect(json_response[:data][:userLogout]).to match(
        authenticable: { email: user.email }
      )
      expect(json_response[:errors]).to be_nil
    end
  end

  context 'when user is not logged in' do
    it 'returns an error' do
      expect(response).not_to include_auth_headers
      expect(user.reload.tokens.keys).to be_empty
      expect(json_response[:data][:userLogout]).to be_nil
      expect(json_response[:errors]).to contain_exactly(
        hash_including(message: 'User was not found or was not logged in.', extensions: { code: 'USER_ERROR' })
      )
    end
  end
end
