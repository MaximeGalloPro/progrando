# spec/system/registration_spec.rb
require 'rails_helper'

RSpec.describe 'User Registration', type: :system do
    before do
        Warden.test_reset!
        visit new_user_registration_path
    end

    context 'when visiting registration page' do
        it 'shows registration form' do
            expect(page).to have_content('Inscription')
            expect(page).to have_field('user[email]')
            expect(page).to have_field('user[password]')
            expect(page).to have_field('user[password_confirmation]')
            expect(page).to have_button("S'inscrire")
        end
    end

    context 'when submitting registration form' do
        it 'registers successfully with valid data' do
            within("form#new_user") do
                fill_in 'user[email]', with: 'nouveau@exemple.com'
                fill_in 'user[password]', with: 'password123'
                fill_in 'user[password_confirmation]', with: 'password123'
                click_button "S'inscrire"
            end

            expect(page).to have_current_path(authenticated_root_path)
            expect(User.find_by_email('nouveau@exemple.com')).to be_present
        end

        it 'prevents submission with invalid email' do
            within("form#new_user") do
                fill_in 'user[email]', with: 'email_invalide'
                fill_in 'user[password]', with: 'password123'
                fill_in 'user[password_confirmation]', with: 'password123'
                click_button "S'inscrire"
            end

            # Vérifie qu'on est toujours sur la page d'inscription
            expect(page).to have_current_path(new_user_registration_path)
            # Vérifie que le champ email contient toujours la valeur invalide
            expect(page).to have_field('user[email]', with: 'email_invalide')
        end

        it 'shows error when passwords do not match' do
            within("form#new_user") do
                fill_in 'user[email]', with: 'test@exemple.com'
                fill_in 'user[password]', with: 'password123'
                fill_in 'user[password_confirmation]', with: 'different123'
                click_button "S'inscrire"
            end

            expect(current_path).to eq('/users')
            expect(page).to have_content('ne correspond pas')
        end

        it 'shows error with short password' do
            within("form#new_user") do
                fill_in 'user[email]', with: 'test@exemple.com'
                fill_in 'user[password]', with: '123'
                fill_in 'user[password_confirmation]', with: '123'
                click_button "S'inscrire"
            end

            expect(current_path).to eq('/users')
            expect(page).to have_content('trop court')
        end
    end
end