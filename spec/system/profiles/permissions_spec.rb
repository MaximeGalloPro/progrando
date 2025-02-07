# spec/system/profiles/permissions_spec.rb
require 'rails_helper'

RSpec.describe 'Profile permissions', type: :request do
    include Devise::Test::IntegrationHelpers

    let!(:organisation) { create(:organisation) }
    let!(:user) { create(:user) }

    context 'with restricted profile' do
        let!(:restricted_profile) do
            create(:profile, organisation: organisation).tap do |profile|
                ProfileRight.where(profile: profile).update_all(authorized: false)
            end
        end

        let!(:user_organisation) do
            create(:user_organisation,
                   user: user,
                   organisation: organisation,
                   profile: restricted_profile
            )
        end

        let!(:target_profile) { create(:profile, :admin, organisation: organisation) }

        before do
            sign_in user
            user.update!(current_organisation_id: organisation.id)
        end

        it 'denies access to edit profile page' do
            get edit_profile_path(target_profile)
            expect(response).to have_http_status(:forbidden)
        end
    end

    context 'with profile viewing rights' do
        let!(:profile_with_rights) { create(:profile, :can_see_profiles, organisation: organisation) }
        let!(:target_profile) { create(:profile, :admin, organisation: organisation) }
        let!(:user_organisation) do
            create(:user_organisation,
                   user: user,
                   organisation: organisation,
                   profile: profile_with_rights,
                   creator: false
            )
        end

        before do
            host! 'localhost'
            sign_in user
            user.update!(
                current_organisation_id: organisation.id,
                super_admin: false
            )
        end

        it 'allows viewing but prevents rights modification' do
            get profile_path(target_profile)
            expect(response).to have_http_status(:success)
            expect(response.body).not_to include('data-controller="permission"')
            expect(response.body).not_to include('data-action="click->permission#toggle"')
        end
    end
end