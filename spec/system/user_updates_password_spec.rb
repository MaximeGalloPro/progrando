# spec/system/user_updates_password_spec.rb
require 'rails_helper'

RSpec.describe "User updates their password", type: :system do
    let!(:user) { create(:user, password: "oldpassword", password_confirmation: "oldpassword") }

    before do
        sign_in user
        visit edit_user_registration_path
    end

    it "allows a user to change their password successfully" do
        fill_in "Nouveau mot de passe", with: "newpassword"
        fill_in "Confirmation du nouveau mot de passe", with: "newpassword"
        fill_in "Mot de passe actuel", with: "oldpassword"
        click_button "Mettre à jour le compte"

        expect(page).to have_content("Votre compte a été mis à jour avec succès")
    end
end
