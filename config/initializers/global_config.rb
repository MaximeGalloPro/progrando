# config/initializers/global_config.rb
module GlobalConfig
    MODELS = ['User',
              'Organisation',
              'OrganisationAccessRequest',
              'Profile',
              'Role',
              'Member',
              'Hike',
              'HikeHistory',
              'HikePath']

    ACTION = %w[index show create update destroy edit new]

    SPECIAL_ACTIONS = {
        'ProfileRight' => %w[toggle_authorization]
    }

    MEMBER_RIGHTS = {
        'Member' => %w[show update],
        'Organisation' => %w[index show],
        'Hike' => %w[index show],
        'HikeHistory' => %w[index show create],
    }

    MEMBER_CAN_SEE_PROFILES = {
        'Member' => %w[index show create update edit],
        'Organisation' => %w[index show create update edit],
        'Hike' => %w[index show create update edit],
        'HikeHistory' => %w[index show create update edit],
        'Profile' => %w[index show create update edit],
        'ProfileRight' => %w[index show create update edit],
        'User' => %w[index show create update edit],
        'Role' => %w[index show create update edit],
        'HikePath' => %w[index show create update edit]
    }

    GUIDE_RIGHTS = {
        'Hike' => %w[index show create update new],
        'HikeHistory' => %w[index show create update],
        'HikePath' => %w[index show create update],
        'Member' => %w[index show],
        'Organisation' => %w[index show]
    }
end