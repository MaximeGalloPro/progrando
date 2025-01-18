# spec/system/organisations_spec.rb
require 'rails_helper'

RSpec.describe 'Organisations', type: :system do
    let!(:organisation) { create(:organisation) }
    let!(:profile) { create(:profile, :admin, organisation: organisation) }
    let!(:user) { create(:user) }
    let!(:user_organisation) { create(:user_organisation, user: user, organisation: organisation, profile: profile) }

    before do
        sign_in user
    end

    describe 'Creating organisation' do
        before do
            visit new_organisation_path
        end

        it "creates an organisation with valid data" do
            fill_in "Nom", with: "Ma Super Organisation"
            fill_in "Site web", with: "https://example.com"
            fill_in "Email", with: "info@example.com"
            fill_in "Téléphone", with: "0123456789"
            fill_in "Nom du contact", with: "Jean Dupont"
            fill_in "Email du contact", with: "jean.dupont@example.com"

            click_button "Enregistrer"

            expect(page).to have_content("Organisation créée avec succès")

            new_org = Organisation.last
            expect(new_org.name).to eq("Ma Super Organisation")
            expect(new_org.email).to eq("info@example.com")
        end

        it "shows errors if the organisation is invalid" do
            # Ne pas remplir le champ Nom
            fill_in "Email", with: "info@example.com"
            click_button "Enregistrer"

            expect(page).to have_content("Name doit être renseigné")
        end
    end

    describe 'Editing an organisation' do
        before do
            visit edit_organisation_path(organisation)
        end

        it 'updates organisation information' do
            fill_in 'Nom', with: 'Nom Modifié'
            click_button 'Enregistrer'

            expect(page).to have_text('Organisation mise à jour avec succès')
            expect(organisation.reload.name).to eq('Nom Modifié')
        end
    end

    describe 'Form navigation' do
        it 'allows returning to index page' do
            visit new_organisation_path
            click_link 'Retour'
            expect(current_path).to eq(organisations_path)
        end
    end
end