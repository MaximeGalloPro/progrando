# db/seeds/business/hiking.rb
include GlobalConfig

HikeHistory.destroy_all
HikePath.destroy_all
Hike.destroy_all

organisations = Organisation.all

organisations.each do |organisation|
    puts "Creating business profiles for #{organisation.name}..."
    profiles = {
        guide: Profile.create!(
            name: "Guide - #{organisation.name}",
            description: 'Peut gérer les randonnées et voir les membres',
            active: true,
            organisation_id: organisation.id
        ),
    }

    puts "Creating business roles..."
    roles = {
        guide: Role.create!(name: 'guide', organisation_id: organisation.id),
    }

    puts "Creating 'Guide' profiles rights for #{organisation.name}..."
    GlobalConfig::GUIDE_RIGHTS.each do |resource, actions|
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

    puts "Creating guide user for #{organisation.name}..."
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
            coordinates: "[{lat: #{base_lat + rand / 100}, lng: #{base_lng + rand / 100}}, {lat: #{base_lat + rand / 100}, lng: #{base_lng + rand / 100}}]",
            organisation_id: organisation.id
        )
    end
end

puts "BUSINESS Seed finished!"
puts "Created:"
puts "- #{Hike.count} hikes"
puts "- #{HikeHistory.count} hike histories"
puts "- #{HikePath.count} hike paths"
