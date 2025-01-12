# db/seeds.rb

# Load config first
load File.join(Rails.root, 'db', 'seeds', 'config', 'global_config.rb')

# Load core
load File.join(Rails.root, 'db', 'seeds', 'core.rb')

# Then load all files in business folder
Dir[File.join(Rails.root, 'db', 'seeds', 'business', '*.rb')].sort.each do |seed|
    load seed
end