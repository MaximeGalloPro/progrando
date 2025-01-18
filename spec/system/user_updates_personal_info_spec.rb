# spec/system/user_updates_personal_info_spec.rb
require 'rails_helper'

RSpec.describe "User updates personal information", type: :system do
    let!(:user) { create(:user, password: "password", password_confirmation: "password") }

    before do
        sign_in user
        visit edit_user_registration_path
    end

    it "updates the name and phone successfully" do
        fill_in "Nom", with: "Jean Dupont"
        fill_in "Téléphone", with: "0606060606"
        click_button "Enregistrer mes informations"

        # Vérifie le message de succès (issu du contrôleur ou de l'I18n)
        expect(page).to have_content("Informations mise à jour avec succès")
    end
end
