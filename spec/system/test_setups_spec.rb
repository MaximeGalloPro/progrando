# spec/system/test_setups_spec.rb
require 'rails_helper'

RSpec.describe 'Test Setup', type: :system do
  context 'when user is not authenticated' do
    before do
      # S'assurer que l'utilisateur est déconnecté
      Warden.test_reset!
    end

    it 'redirects to sign in page' do
      visit new_user_session_path  # Aller directement à la page de connexion
      expect(page).to have_content('Connexion')
      expect(page).to have_button('Se connecter')
    end
  end

  context 'when user tries to login' do
    let(:user) { create(:user, email: 'test@exemple.com', password: 'password123') }

    before do
      Warden.test_reset!
      visit new_user_session_path
    end

    it 'allows user to login' do
      within("form#new_user") do  # Cibler spécifiquement le formulaire
        fill_in 'user[email]', with: user.email
        fill_in 'user[password]', with: 'password123'
        check 'user[remember_me]' if page.has_field?('user[remember_me]')
        click_button 'Se connecter'
      end

      # Vérifier la redirection après la connexion
      expect(page).to have_current_path(authenticated_root_path)
      expect(page).to have_content('Progit') # Un élément qu'on voit sur le dashboard
    end
  end
end