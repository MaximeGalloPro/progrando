# db/seeds/core.rb
include GlobalConfig

User.destroy_all
Organisation.destroy_all
Profile.destroy_all
ProfileRight.destroy_all
Member.destroy_all
Role.destroy_all

puts "Creating super admin user..."
super_admin = User.create!(
    email: 'super_admin@exemple.com',
    password: 'password123',
    password_confirmation: 'password123',
    super_admin: true
)

puts "Creating organisations..."
organisations = [
    Organisation.create!(
        name: 'Organisation 1',
        slug: 'org1',
        email: 'contact@org1.com'
    ),
    Organisation.create!(
        name: 'Organisation 2',
        slug: 'org2',
        email: 'contact@org2.com'
    )
]

puts "Creating multi-org admin user..."
multi_org_admin = User.create!(
    email: 'multi_org_admin@exemple.com',
    password: 'password123',
    password_confirmation: 'password123'
)

puts "Creating creator user..."
creator_user = User.create!(
    email: 'creator@exemple.com',
    password: 'password123',
    password_confirmation: 'password123'
)

puts "No organisation user..."
User.create!(
    email: 'no_orga@exemple.com',
    password: 'password123',
    password_confirmation: 'password123'
)

organisations.each do |organisation|
    puts "Creating profiles for #{organisation.name}..."
    profiles = {
        creator: Profile.create!(
            name: "Createur",
            description: 'Créateur et a donc accès complet à toutes les fonctionnalités',
            active: true,
            organisation_id: organisation.id
        ),
        admin: Profile.create!(
            name: "Admin",
            description: 'Accès complet à toutes les fonctionnalités',
            active: true,
            organisation_id: organisation.id
        ),
        member: Profile.create!(
            name: "Membre - #{organisation.name}",
            description: 'Peut voir et s\'inscrire aux randonnées',
            active: true,
            organisation_id: organisation.id
        ),
        member_with_profiles: Profile.create!(
            name: "Membre avec accès profils - #{organisation.name}",
            description: 'Peut voir et gérer les profils en plus des fonctionnalités de membre',
            active: true,
            organisation_id: organisation.id
        )
    }

    puts "Linking multi-org admin to organisations..."
    UserOrganisation.create!(user: multi_org_admin,
                             organisation: organisation,
                             profile: profiles[:admin])

    puts "Linking creator to organisations..."
    UserOrganisation.create!(user: creator_user,
                             organisation: organisation,
                             profile: profiles[:creator],
                             creator: true)

    puts "Creating roles..."
    roles = {
        admin: Role.create!(name: 'admin', organisation_id: organisation.id),
        member: Role.create!(name: 'member', organisation_id: organisation.id)
    }

    puts "Creating Multi-Org member for #{organisation.name}..."
    Member.create!(
        name: "Multi-Org Admin",
        email: multi_org_admin.email,
        phone: '0123456789',
        role: Role.find_by(name: 'admin', organisation_id: organisation.id),
        organisation_id: organisation.id)

    puts "Creating admin users for #{organisation.name}..."
    admin_user = User.create!(
        email: "admin@#{organisation.slug}.com",
        password: 'password123',
        password_confirmation: 'password123'
    )

    puts "Linking admin users to organisations..."
    UserOrganisation.create!(user: admin_user, organisation: organisation, profile: profiles[:admin])

    puts "Creating admin member for #{organisation.name}..."
    admin_member = Member.create!(
        name: "Admin #{organisation.slug.upcase}",
        email: admin_user.email,
        phone: '0123456789',
        role: roles[:admin],
        organisation_id: organisation.id)

    puts "Creating basics members and users for #{organisation.name}..."
    3.times do |i|
        member_user = User.create!(
            email: "member#{i + 1}@#{organisation.slug}.com",
            password: 'password123',
            password_confirmation: 'password123'
        )

        UserOrganisation.create!(user: member_user, organisation: organisation, profile: profiles[:member])

        member = Member.create!(
            name: "Membre #{i + 1} #{organisation.slug.upcase}",
            email: member_user.email,
            phone: "012345678#{i + 1}",
            role: roles[:member],
            organisation_id: organisation.id,
            )
        puts "Member #{member.name} created in organisation #{organisation.slug.upcase} with id: #{organisation.id}!"
    end

    puts "Creating 'Admin' profile rights for #{organisation.name}..."
    GlobalConfig::MODELS.each do |resource|
        GlobalConfig::ACTION.each do |action|
            ProfileRight.create!(
                profile: profiles[:admin],
                resource: resource,
                action: action,
                authorized: true,
                organisation_id: organisation.id
            )
        end
    end

    GlobalConfig::SPECIAL_ACTIONS.each do |resource, actions|
        actions.each do |action|
            ProfileRight.find_or_create_by(
                profile: profiles[:admin],
                resource: resource,
                action: action,
                authorized: true,
                organisation_id: organisation.id
            )
        end
    end

    puts "Creating 'Member' profile rights for #{organisation.name}..."
    GlobalConfig::MEMBER_RIGHTS.each do |resource, actions|
        actions.each do |action|
            ProfileRight.create!(
                profile: profiles[:member],
                resource: resource,
                action: action,
                authorized: true,
                organisation_id: organisation.id
            )
        end
    end

    puts "Creating 'Member with Profiles' rights for #{organisation.name}..."
    GlobalConfig::MEMBER_CAN_SEE_PROFILES.each do |resource, actions|
        actions.each do |action|
            ProfileRight.create!(
                profile: profiles[:member_with_profiles],
                resource: resource,
                action: action,
                authorized: true,
                organisation_id: organisation.id
            )
        end
    end

    # GlobalConfig::SPECIAL_ACTIONS.each do |resource, actions|
    #     actions.each do |action|
    #         ProfileRight.find_or_create_by(
    #             profile: profiles[:member_with_profiles],
    #             resource: resource,
    #             action: action,
    #             authorized: true,
    #             organisation_id: organisation.id
    #         )
    #     end
    # end
end

puts "Creating cross-organisation access requests..."
organisations.each do |org|
    org_users = UserOrganisation.where(organisation: org)
                                .includes(:user)
                                .reject { |uo| uo.user.super_admin }

    org_users.each do |user_org|
        user = user_org.user
        member = Member.find_by(email: user.email, organisation_id: org.id)

        if member&.role
            other_orgs = organisations.reject { |other_org| other_org.id == org.id }

            other_orgs.each do |other_org|
                next if UserOrganisation.exists?(user: user, organisation: other_org)
                next if OrganisationAccessRequest.exists?(user: user, organisation: other_org)

                begin
                    OrganisationAccessRequest.create!(
                        user: user,
                        organisation: other_org,
                        status: 'pending',
                        role: member.role.name,
                        message: "Je suis #{member.role.name} de #{org.name} et souhaite rejoindre #{other_org.name}"
                    )
                    puts "Created access request for #{user.email} (#{member.role.name}) to join #{other_org.name}"
                rescue ActiveRecord::RecordInvalid => e
                    puts "Failed to create access request for #{user.email} to join #{other_org.name}: #{e.message}"
                end
            end
        else
            puts "Skipping access request for #{user.email} - no member record or role found"
        end
    end
end

puts "Created:"
puts "- #{Organisation.count} organisations"
puts "- #{Profile.count} profiles"
puts "- #{ProfileRight.count} profile rights"
puts "- #{Role.count} roles"
puts "- #{User.count} users"
puts "- #{Member.count} members"
puts "\n ### CORE Seed finished! ###\n"