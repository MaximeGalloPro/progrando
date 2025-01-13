# db/seeds/config/global_config.rb

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
        'HikeHistory' => %w[index show create]

    }

    GUIDE_RIGHTS = {
        'Hike' => %w[index show create update new],
        'HikeHistory' => %w[index show create update],
        'HikePath' => %w[index show create update],
        'Member' => %w[index show],
        'Organisation' => %w[index show]
    }
end