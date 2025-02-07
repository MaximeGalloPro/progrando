# spec/system/password_reset_spec.rb
require 'rails_helper'

RSpec.describe 'Password Reset', type: :system do
    let!(:user) { create(:user, email: "testeur#{Time.now.to_i}@exemple.com") }

    before do
        Warden.test_reset!
        visit new_user_password_path
    end

    context 'when visiting password reset page' do
        it 'shows reset password form' do
            expect(page).to have_content('Mot de passe oublié ?')
            expect(page).to have_field('user[email]')
            expect(page).to have_button('Réinitialiser mon mot de passe')
        end
    end

    context 'when submitting password reset form' do
        it 'sends reset instructions for existing email' do
            within("form") do
                fill_in 'user[email]', with: user.email
                click_button 'Réinitialiser mon mot de passe'
            end

            expect(page).to have_content(I18n.t('devise.passwords.send_instructions'))
        end

        it 'shows error for non-existing email' do
            within("form") do
                fill_in 'user[email]', with: "non_existant#{Time.now.to_i}@exemple.com"
                click_button 'Réinitialiser mon mot de passe'
            end

            expect(page).to have_content("n'a pas été trouvé")
        end
        it 'prevents submission with invalid email' do
            within("form#new_user") do
                fill_in 'user[email]', with: 'email_invalide'
                click_button 'Réinitialiser mon mot de passe'
            end

            # Vérifie qu'on est toujours sur la page d'inscription
            expect(page).to have_current_path('/users/password/new')
            # Vérifie que le champ email contient toujours la valeur invalide
            expect(page).to have_field('user[email]', with: 'email_invalide')
        end
    end
end