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
        let(:admin_profile) { create(:profile, :admin, organisation: organisation) }
        let(:admin) { create(:admin) }
        let(:member_profile) { create(:profile, :member, organisation: organisation) }

        let!(:admin_organisation) do
            create(:user_organisation,
                   user: admin,
                   organisation: organisation,
                   profile: admin_profile)
        end

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
                click_link href: edit_organisation_access_request_path(access_request)
                expect(page).to have_content("Affectez un profil à ce nouveau membre")
            end

            context 'with valid profile selection' do
                it 'approves the request' do
                    select member_profile.name, from: 'organisation_access_request_profile_id'

                    expect {
                        click_button 'Accepter la demande'
                    }.to change { UserOrganisation.count }.by(1)

                    access_request.reload
                    expect(access_request.status).to eq('approved')
                    expect(access_request.processed_by_id).to eq(admin.id)
                    expect(access_request.processed_at).to be_present

                    # Vérifier l'association utilisateur-organisation
                    user_org = UserOrganisation.last
                    expect(user_org.user).to eq(user)
                    expect(user_org.organisation).to eq(organisation)
                    expect(user_org.profile).to eq(member_profile)

                    expect(page).to have_current_path(organisation_access_requests_path)
                    expect(page).to have_content(I18n.t('organisation_access_requests.update.success'))
                end
            end

            context 'without selecting a profile' do
                it 'shows an error' do
                    click_button 'Accepter la demande'

                    expect(page).to have_content("Affectez un profil à ce nouveau membre")
                    expect(UserOrganisation.count).to eq(0)
                    expect(access_request.reload.status).to eq('pending')
                end
            end
        end

        context 'when rejecting a request' do
            it 'updates the request status' do
                expect {
                    click_link href: reject_organisation_access_request_path(access_request)
                    page.accept_confirm if page.has_content?('Êtes-vous sûr ?')
                }.not_to change { UserOrganisation.count }

                access_request.reload
                expect(access_request.status).to eq('rejected')
                expect(access_request.processed_by_id).to eq(admin.id)
                expect(access_request.processed_at).to be_present

                expect(page).to have_current_path(organisation_access_requests_path)
                expect(page).to have_content(I18n.t('organisation_access_requests.reject.success'))
            end
        end
    end
end