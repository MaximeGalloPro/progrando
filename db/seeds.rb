puts "Cleaning database..."
ProfileRight.destroy_all
Profile.destroy_all
Member.destroy_all
Role.destroy_all
User.destroy_all
HikeHistory.destroy_all
HikePath.destroy_all
Hike.destroy_all
Organisation.destroy_all

RESOURCES = ['Hike', 'HikeHistory', 'HikePath', 'Member', 'User']

GUIDE_RIGHTS = {
    'Hike' => %w[index show create update new],
    'HikeHistory' => %w[index show create update],
    'HikePath' => %w[index show create update],
    'Member' => %w[index show],
}

MEMBER_RIGHTS = {
    'Hike' => %w[index show],
    'HikeHistory' => %w[index show create],
    'Member' => %w[show update]
}

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
        name: 'Club Alpin Français',
        slug: 'caf',
        email: 'contact@caf.com'
    ),
    Organisation.create!(
        name: 'Randonneurs des Alpes',
        slug: 'rda',
        email: 'contact@rda.com'
    )
]

puts "Creating multi-org admin user..."
multi_org_admin = User.create!(
    email: 'multi_org_admin@exemple.com',
    password: 'password123',
    password_confirmation: 'password123'
)

organisations.each do |organisation|
    puts "Creating profiles for #{organisation.name}..."
    profiles = {
        admin: Profile.create!(
            name: "Administrateur - #{organisation.name}",
            description: 'Accès complet à toutes les fonctionnalités',
            active: true,
            organisation_id: organisation.id
        ),
        guide: Profile.create!(
            name: "Guide - #{organisation.name}",
            description: 'Peut gérer les randonnées et voir les membres',
            active: true,
            organisation_id: organisation.id
        ),
        member: Profile.create!(
            name: "Membre - #{organisation.name}",
            description: 'Peut voir et s\'inscrire aux randonnées',
            active: true,
            organisation_id: organisation.id
        )
    }

    puts "Creating roles..."
    roles = {
        admin: Role.create!(name: 'admin', organisation_id: organisation.id),
        guide: Role.create!(name: 'guide', organisation_id: organisation.id),
        member: Role.create!(name: 'member', organisation_id: organisation.id)
    }


    Member.create!(
        name: "Multi-Org Admin",
        email: multi_org_admin.email,
        phone: '0123456789',
        role: Role.find_by(name: 'admin', organisation_id: organisation.id),
        organisation_id: organisation.id)

    UserOrganisation.create!(user: multi_org_admin, organisation: organisation, profile: profiles[:admin])

    puts "Creating users and members..."
    # Admin
    admin_user = User.create!(
        email: "admin@#{organisation.slug}.com",
        password: 'password123',
        password_confirmation: 'password123'
    )

    UserOrganisation.create!(user: admin_user, organisation: organisation, profile: profiles[:admin])

    admin_member = Member.create!(
        name: "Admin #{organisation.slug.upcase}",
        email: admin_user.email,
        phone: '0123456789',
        role: roles[:admin],
        organisation_id: organisation.id,
    )

    # Guide
    guide_user = User.create!(
        email: "guide@#{organisation.slug}.com",
        password: 'password123',
        password_confirmation: 'password123'
    )

    UserOrganisation.create!(user: guide_user, organisation: organisation, profile: profiles[:guide])

    guide_member = Member.create!(
        name: "Guide #{organisation.slug.upcase}",
        email: guide_user.email,
        phone: '0123456780',
        role: roles[:guide],
        organisation_id: organisation.id,
    )

    # Regular members
    3.times do |i|
        member_user = User.create!(
            email: "member#{i+1}@#{organisation.slug}.com",
            password: 'password123',
            password_confirmation: 'password123'
        )

        UserOrganisation.create!(user: member_user, organisation: organisation, profile: profiles[:member])

        member = Member.create!(
            name: "Membre #{i+1} #{organisation.slug.upcase}",
            email: member_user.email,
            phone: "012345678#{i+1}",
            role: roles[:member],
            organisation_id: organisation.id,
        )
        puts "Member #{member.name} created in organisation #{organisation.slug.upcase} with id: #{organisation.id}!"
    end

    puts "Creating profile rights..."
    # Admin rights
    RESOURCES.each do |resource|
        %w[index show create update destroy edit new].each do |action|
            ProfileRight.create!(
                profile: profiles[:admin],
                resource: resource,
                action: action,
                authorized: true,
                organisation_id: organisation.id
            )
        end
    end

    # Guide rights
    GUIDE_RIGHTS.each do |resource, actions|
        actions.each do |action|
            ProfileRight.create!(
                profile: profiles[:guide],
                resource: resource,
                action: action,
                authorized: true,
                organisation_id: organisation.id
            )
        end
    end

    # Member rights
    MEMBER_RIGHTS.each do |resource, actions|
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

    puts "Creating hikes for #{organisation.name}..."
    hike_data = [
        {
            number: 1,
            day: 1,
            difficulty: 3,
            starting_point: "#{organisation.slug} - #{organisation.slug == 'caf' ? 'Col du Galibier' : 'Col de la Croix de Fer'}",
            trail_name: "#{organisation.slug} - #{organisation.slug == 'caf' ? 'Sentier des Cimes' : 'Circuit des Lacs'}",
            carpooling_cost: 5.50,
            distance_km: 12.5,
            elevation_gain: 450,
            elevation_loss: 450,
            altitude_min: 800,
            altitude_max: 1250,
        },
        {
            number: 2,
            day: 2,
            difficulty: 4,
            starting_point: "#{organisation.slug} - #{organisation.slug == 'caf' ? 'Refuge du Goûter' : 'Refuge de la Vanoise'}",
            trail_name: "#{organisation.slug} - #{organisation.slug == 'caf' ? 'Tour du Mont-Blanc' : 'Tour des Écrins'}",
            carpooling_cost: 7.00,
            distance_km: 15.0,
            elevation_gain: 600,
            elevation_loss: 600,
            altitude_min: 1200,
            altitude_max: 1800,
        }
    ]

    hikes = hike_data.map do |data|
        Hike.create!(data.merge(
            openrunner_ref: data[:number],
            organisation_id: organisation.id
        ))
    end

    puts "Creating hike histories..."
    members = Member.where(organisation_id: organisation.id)

    15.times do |i|
        date = Date.today - (i + 1).days
        HikeHistory.create!(
            hiking_date: date,
            departure_time: ["08:00", "09:00", "14:00"].sample,
            day_type: ["morning", "afternoon"].sample,
            carpooling_cost: rand(4.0..8.0).round(2),
            member_id: members.sample.id,
            hike_id: hikes.sample.id,
            organisation_id: organisation.id
        )
    end

    puts "Creating hike paths..."
    hikes.each do |hike|
        base_lat = organisation.slug == 'caf' ? 45.1 : 45.5
        base_lng = organisation.slug == 'caf' ? 5.1 : 5.5

        HikePath.create!(
            hike_id: hike.id,
            coordinates: "[{lat: #{base_lat + rand/100}, lng: #{base_lng + rand/100}}, {lat: #{base_lat + rand/100}, lng: #{base_lng + rand/100}}]",
            organisation_id: organisation.id
        )
    end
end

puts "Seed finished!"
puts "Created:"
puts "- #{Organisation.count} organisations"
puts "- #{Profile.count} profiles"
puts "- #{ProfileRight.count} profile rights"
puts "- #{Role.count} roles"
puts "- #{User.count} users"
puts "- #{Member.count} members"
puts "- #{Hike.count} hikes"
puts "- #{HikeHistory.count} hike histories"
puts "- #{HikePath.count} hike paths"