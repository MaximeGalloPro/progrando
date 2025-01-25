# spec/system/profiles/prevent_privilege_elevation_spec.rb
require 'rails_helper'

RSpec.describe 'Profile rights privilege elevation prevention', type: :system do
    let!(:organisation) { create(:organisation) }
    let!(:admin_profile) { create(:profile, :admin, organisation: organisation) }
    let!(:admin_user) { create(:user) }
    let!(:admin_user_organisation) do
        create(:user_organisation,
               user: admin_user,
               organisation: organisation,
               profile: admin_profile)
    end

    before do
        sign_in admin_user
        admin_user.update!(current_organisation_id: organisation.id)
        visit edit_profile_path(admin_profile)
    end

    it 'prevents modifying own profile rights and shows error', js: true do
        profile_right = ProfileRight.find_by(profile: admin_profile)
        initial_authorization = profile_right.authorized
        initial_text = initial_authorization ? 'Autorisé' : 'Non autorisé'

        within('.table-responsive') do
            badge = first('.badge')
            badge.click
            expect(badge.text).to eq(initial_text)
        end

        expect(profile_right.reload.authorized).to eq(initial_authorization)
    end
end