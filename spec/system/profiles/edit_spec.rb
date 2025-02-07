# spec/system/profiles/edit_spec.rb
require 'rails_helper'

RSpec.describe 'Profile editing', type: :system do
    let!(:organisation) { create(:organisation) }
    let!(:admin_profile) { create(:profile, :admin, organisation: organisation) }
    let!(:admin_user) { create(:user) }
    let!(:user_organisation) do
        create(:user_organisation,
               user: admin_user,
               organisation: organisation,
               profile: admin_profile,
               creator: true)
    end
    let!(:profile) { create(:profile, :member, organisation: organisation) }

    before do
        sign_in admin_user
        admin_user.update!(current_organisation_id: organisation.id)
        visit edit_profile_path(profile)
    end

    it 'displays the edit form with profile permissions', js: true do
        expect(page).to have_content('Editer un profil')
        expect(page).to have_field('Nom')
        expect(page).to have_field('Description')
    end

    it 'shows permissions table with proper elements', js: true do
        expect(page).to have_content('Permissions du profil')
        within('.table-responsive') do
            expect(page).to have_content('Hike')
            expect(page).to have_content('index')
            expect(page).to have_css('.badge')
        end
    end

    it 'toggles permission status when clicking badge', js: true do
        within('.table-responsive') do
            first_badge = first('.badge')
            initial_state = first_badge.text
            first_badge.click
            wait_for_ajax
            expect(first_badge.text).not_to eq initial_state
        end
    end

    it 'shows tooltips when hovering over actions', js: true do
        within('.table-responsive') do
            tooltip_element = first('[data-bs-toggle="tooltip"]')
            page.execute_script('var tooltip = new bootstrap.Tooltip(arguments[0]); tooltip.show()', tooltip_element.native)
            wait_for_ajax
            expect(tooltip_element['data-bs-original-title']).to match(/Permet d/)
        end
    end

    it 'validates presence of name', js: true do
        fill_in 'Nom', with: ''
        click_button 'Enregistrer'
        expect(page).to have_content('Name doit être renseigné')
    end

    it 'toggles permission status when clicking badge', js: true do
        within('.table-responsive') do
            badge = first('.badge')
            initial_text = badge.text
            initial_class = badge['class']

            badge.click
            wait_for_ajax

            expect(badge.text).not_to eq initial_text
            expect(badge['class']).not_to eq initial_class
            expect(badge['class']).to include(initial_text == 'Autorisé' ? 'bg-danger' : 'bg-success')
            expect(badge.text).to eq(initial_text == 'Autorisé' ? 'Non autorisé' : 'Autorisé')
        end
    end
end