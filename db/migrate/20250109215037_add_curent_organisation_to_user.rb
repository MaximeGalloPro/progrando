class AddCurentOrganisationToUser < ActiveRecord::Migration[7.0]
    def change
        if table_exists? :users
            add_column :users, :current_organisation_id, :integer unless column_exists? :users, :current_organisation_id
        end
    end
end