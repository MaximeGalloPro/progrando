class AddOrganisationsTable < ActiveRecord::Migration[7.0]
    def change
        unless table_exists? :organisations
            create_table :organisations do |t|
                t.string :name
                t.string :slug
                t.string :url
                t.string :logo_url
                t.string :description
                t.string :location
                t.string :email
                t.string :phone
                t.string :contact_name
                t.string :contact_email
                t.string :contact_phone
                t.string :contact_position
                t.string :contact_language
                t.timestamps
            end
        end

        add_column :hike_histories, :organisation_id, :integer unless column_exists?(:hike_histories, :organisation_id)
        add_column :hike_paths, :organisation_id, :integer unless column_exists?(:hike_paths, :organisation_id)
        add_column :hikes, :organisation_id, :integer unless column_exists?(:hikes, :organisation_id)
        add_column :members, :organisation_id, :integer unless column_exists?(:members, :organisation_id)
        add_column :profile_rights, :organisation_id, :integer unless column_exists?(:profile_rights, :organisation_id)
        add_column :profiles, :organisation_id, :integer unless column_exists?(:profiles, :organisation_id)
        add_column :rights, :organisation_id, :integer unless column_exists?(:rights, :organisation_id)
        add_column :roles, :organisation_id, :integer unless column_exists?(:roles, :organisation_id)
        add_column :users, :organisation_id, :integer unless column_exists?(:users, :organisation_id)
    end
end
