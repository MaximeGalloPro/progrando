class AddRightsForRoles < ActiveRecord::Migration[7.0]
    def change
        create_table :rights do |t|
            t.integer :role_id
            t.string :model
            t.boolean :create
            t.boolean :read
            t.boolean :update
            t.boolean :delete
        end
    end
end
