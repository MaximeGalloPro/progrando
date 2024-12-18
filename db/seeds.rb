# db/seeds.rb

puts "Cleaning database..."
# L'ordre de suppression est important à cause des dépendances
ProfileRight.destroy_all
Profile.destroy_all
Member.destroy_all
Role.destroy_all
User.destroy_all
Guide.destroy_all
HikeHistory.destroy_all
HikePath.destroy_all
Hike.destroy_all

puts "Creating profiles..."
admin_profile = Profile.create!(
    name: 'Administrateur',
    description: 'Accès complet à toutes les fonctionnalités',
    active: true
)

guide_profile = Profile.create!(
    name: 'Guide',
    description: 'Peut gérer les randonnées et voir les membres',
    active: true
)

member_profile = Profile.create!(
    name: 'Membre',
    description: 'Peut voir et s\'inscrire aux randonnées',
    active: true
)

puts "Creating roles..."
admin_role = Role.create!(name: 'admin')
guide_role = Role.create!(name: 'guide')
member_role = Role.create!(name: 'member')

puts "Creating admin user..."
admin_user = User.create!(
    email: 'admin@example.com',
    password: 'password123',
    password_confirmation: 'password123',
    profile: admin_profile
)

puts "Creating admin member..."
admin_member = Member.create!(
    name: 'Admin User',
    email: admin_user.email,
    phone: '0123456789',
    role: admin_role
)

puts "Creating profile rights..."

# Liste des ressources à gérer
RESOURCES = ['Guide', 'Hike', 'HikeHistory', 'HikePath', 'Member', 'User']

# Droits pour l'administrateur (accès total)
RESOURCES.each do |resource|
    %w[index show create update destroy edit].each do |action|
        ProfileRight.create!(
            profile: admin_profile,
            resource: resource,
            action: action,
            authorized: true
        )
    end
end

# Droits pour les guides
GUIDE_RIGHTS = {
    'Hike' => %w[index show create update],
    'HikeHistory' => %w[index show create update],
    'HikePath' => %w[index show create update],
    'Member' => %w[index show],
    'Guide' => %w[index show]
}

GUIDE_RIGHTS.each do |resource, actions|
    actions.each do |action|
        ProfileRight.create!(
            profile: guide_profile,
            resource: resource,
            action: action,
            authorized: true
        )
    end
end

# Droits pour les membres
MEMBER_RIGHTS = {
    'Hike' => %w[index show],
    'HikeHistory' => %w[index show create],
    'Member' => %w[show update]
}

MEMBER_RIGHTS.each do |resource, actions|
    actions.each do |action|
        ProfileRight.create!(
            profile: member_profile,
            resource: resource,
            action: action,
            authorized: true
        )
    end
end

puts "Creating sample guide..."
guide = Guide.create!(
    name: 'Jean Guide',
    phone: '0687654321',
    email: 'guide@example.com'
)

puts "Creating sample hike..."
hike = Hike.create!(
    number: 1,
    day: 1, # 1 = Lundi
    difficulty: 3,
    starting_point: "Place du village",
    trail_name: "Sentier des crêtes",
    carpooling_cost: 5.50,
    distance_km: 12.5,
    elevation_gain: 450,
    elevation_loss: 450,
    altitude_min: 800,
    altitude_max: 1250,
    openrunner_ref: "12345678"
)

puts "Creating sample hike history..."
HikeHistory.create!(
    hiking_date: Date.today,
    departure_time: "09:00",
    day_type: "morning",
    carpooling_cost: 5.50,
    member_id: admin_member.id,
    hike_id: hike.id,
    openrunner_ref: hike.openrunner_ref
)

puts "Creating sample hike path..."
HikePath.create!(
    hike_id: hike.id,
    coordinates: "[{lat: 45.123, lng: 5.123}, {lat: 45.124, lng: 5.124}]"
)

puts "Seed finished!"
puts "Created:"
puts "- #{Profile.count} profiles"
puts "- #{ProfileRight.count} profile rights"
puts "- #{Role.count} roles"
puts "- #{User.count} users"
puts "- #{Member.count} members"
puts "- #{Guide.count} guides"
puts "- #{Hike.count} hikes"
puts "- #{HikeHistory.count} hike histories"
puts "- #{HikePath.count} hike paths"