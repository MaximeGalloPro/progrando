# frozen_string_literal: true

# app/services/admin_profile_setup_service.rb
class AdminProfileSetupService
    def initialize(organisation, admin_profile)
        @organisation = organisation
        @admin_profile = admin_profile
    end

    def setup
        create_admin_user
        create_admin_role
        create_admin_member
        setup_admin_rights
        setup_special_rights
    end

    private

    def create_admin_user
        @admin_user = User.create!(
            email: "admin@#{@organisation.slug}.com",
            password: 'password123',
            password_confirmation: 'password123'
        )

        UserOrganisation.create!(
            user: @admin_user,
            organisation: @organisation,
            profile: @admin_profile
        )
    end

    def create_admin_role
        @admin_role = Role.create!(
            name: 'admin',
            organisation_id: @organisation.id
        )
    end

    def create_admin_member
        Member.create!(
            name: "Admin #{@organisation.slug.upcase}",
            email: @admin_user.email,
            phone: '0123456789',
            role: @admin_role,
            organisation_id: @organisation.id
        )
    end

    def setup_admin_rights
        MODELS.each do |resource|
            ACTION.each do |action|
                ProfileRight.create!(
                    profile: @admin_profile,
                    resource: resource,
                    action: action,
                    authorized: true,
                    organisation_id: @organisation.id
                )
            end
        end
    end

    def setup_special_rights
        SPECIAL_ACTIONS.each do |resource, actions|
            actions.each do |action|
                ProfileRight.find_or_create_by(
                    profile: @admin_profile,
                    resource: resource,
                    action: action,
                    authorized: true,
                    organisation_id: @organisation.id
                )
            end
        end
    end
end
