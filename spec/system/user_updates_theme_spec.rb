# spec/system/user_updates_theme_spec.rb
require 'rails_helper'

RSpec.describe "User updates theme", type: :system do
    let!(:user) do
        create(:user, password: "oldpassword", password_confirmation: "oldpassword")
    end

    before do
        # On connecte l'utilisateur
        sign_in user
        # On va sur la page /users/edit
        visit edit_user_registration_path
    end

    it "changes the interface theme successfully" do
        # Vérifier qu'on est bien sur la page de modification de compte
        expect(page).to have_current_path(edit_user_registration_path)

        # Dans la section "Personnalisation de l'interface"
        # Sélectionne 'Max' par exemple
        select "Max", from: "Thème de l'interface"

        # Clique sur "Enregistrer le thème"
        click_button "Enregistrer le thème"

        # On s'attend à voir un message de succès (selon ton i18n fr.yml)
        expect(page).to have_content("Thème mis à jour avec succès")
    end
end
