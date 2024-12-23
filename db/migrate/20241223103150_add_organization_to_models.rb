class AddOrganizationToModels < ActiveRecord::Migration[7.0]
    def change
        %w[profiles members roles users guides hike_histories hike_paths hikes profile_rights].each do |table|
            if table_exists? table and !column_exists? table, :organization_id
                add_reference table, :organization, null: false, foreign_key: true
            end
        end
    end
end
