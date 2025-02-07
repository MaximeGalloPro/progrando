# spec/models/profile_right_spec.rb
require 'rails_helper'

RSpec.describe ProfileRight, type: :model do
    describe 'validations' do
        describe 'base validations' do
            it { should validate_presence_of(:resource) }
            it { should validate_presence_of(:action) }
            it { should validate_uniqueness_of(:profile_id).scoped_to([:resource, :action]) }
            it { should belong_to(:organisation) }
            it { should belong_to(:profile) }
        end

        describe '#cannot_modify_own_profile_rights' do
            let(:organisation) { create(:organisation) }
            let(:admin_profile) { create(:profile, :admin, organisation: organisation) }
            let(:admin_user) { create(:user) }
            let(:profile_right) { create(:profile_right, profile: admin_profile, organisation: organisation) }
            before do
                allow(Current).to receive(:user).and_return(admin_user)
                create(:user_organisation, user: admin_user, organisation: organisation, profile: admin_profile)
            end
            it 'prevents updating own profile rights' do
                profile_right.authorized = !profile_right.authorized
                expect(profile_right.save).to be false
                expect(profile_right.errors[:base]).to include(I18n.t('profiles.toggle_authorization.cannot_modify_own_profile'))
            end
        end
    end
end