# spec/system/organisations/request_access_spec.rb
require 'rails_helper'

RSpec.describe 'Organisation Access Request', type: :system do
    let(:organisation) { create(:organisation) }
    let(:user) { create(:user) }

    before do
        sign_in user
    end

    describe 'requesting access to an organisation' do
        context 'when visiting the request form' do
            before do
                visit request_access_organisation_path(organisation)
            end

            it 'displays the request form' do
                expect(page).to have_content("Demande d'accès à #{organisation.name}")
                expect(page).to have_field('Email')
                expect(page).to have_field('Nom')
                expect(page).to have_field('Téléphone')
                expect(page).to have_field('Message de demande')
                expect(page).to have_field('Rôle souhaité')
            end

            context 'when submitting a valid request' do
                before do
                    fill_in 'Nom', with: 'John Doe'
                    fill_in 'Email', with: user.email
                    fill_in 'Téléphone', with: '0123456789'
                    fill_in 'Message de demande', with: 'Je souhaite rejoindre votre organisation'
                    select 'Membre', from: 'Rôle souhaité'

                    # Pour les tests d'emails
                    # perform_enqueued_jobs do
                    click_button 'Envoyer la demande'
                    # end
                end

                it 'creates a new access request' do
                    expect(OrganisationAccessRequest.find_by(user_id: user.id, organisation_id: organisation.id)).to be_present
                    expect(page).to have_content(I18n.t('organisations.request_access.success'))
                end

                it 'creates a new member' do
                    member = Member.last
                    expect(member.name).to eq('John Doe')
                    expect(member.email).to eq(user.email)
                    expect(member.phone).to eq('0123456789')
                end

                # it 'sends a notification email' do
                #     expect(ActionMailer::Base.deliveries.last.subject).to include('Nouvelle demande d\'accès')
                # end
            end

            context 'when a request already exists' do
                before do
                    create(:organisation_access_request, user: user, organisation: organisation)
                    fill_in 'Nom', with: 'John Doe'
                    click_button 'Envoyer la demande'
                end

                it 'shows an error message' do
                    expect(page).to have_content(I18n.t('organisations.request_access.already_requested'))
                end
            end
        end
    end

    describe 'processing access requests' do
        let(:admin) { create(:admin) }
        let(:member_profile) { create(:profile, :member, organisation: organisation) }
        let!(:access_request) do
            create(:organisation_access_request,
                   user: user,
                   organisation: organisation,
                   status: 'pending',
                   role: 'member')
        end

        before do
            sign_in admin
            visit organisation_access_requests_path
        end

        context 'when accepting a request' do
            before do
                # Cliquer sur le bouton qui ouvre la modal
                button_id = "organisation_access_requests_#{access_request.id}_edit"
                find_button(id: button_id).click
                # Attendre que la modal soit chargée
                expect(page).to have_content("Affectez un profil à ce nouveau membre")
            end

            context 'with valid profile selection' do
                it 'approves the request' do
                    expect(page).to have_selector('.modal', visible: true)

                    within('.modal') do
                        first_member_option = first('select option', text: /Membre/)
                        select first_member_option.text, from: 'organisation_access_request_profile_id'
                    end

                    expect {
                        click_button 'Accepter la demande'
                    }.to change { UserOrganisation.count }.by(1)

                    access_request.reload
                    expect(access_request.status).to eq('approved')
                    expect(access_request.processed_by_id).to eq(admin.id)
                    expect(access_request.processed_at).to be_present

                    user_org = UserOrganisation.last
                    expect(user_org.user).to eq(user)
                    expect(user_org.organisation).to eq(organisation)
                    expect(user_org.profile).to be_present
                    expect(user_org.profile.name).to match(/Membre/)

                    expect(page).to have_current_path(organisation_access_requests_path)
                    expect(page).to have_content(I18n.t('organisation_access_requests.update.success'))
                end
            end
        end
    end
end