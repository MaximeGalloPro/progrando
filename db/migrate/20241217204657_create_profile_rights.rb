class CreateProfileRights < ActiveRecord::Migration[7.0]
    def change

        unless table_exists?(:profiles)
            create_table :profiles do |t|
                t.string :name, null: false
                t.string :description
                t.boolean :active, default: true

                t.timestamps
            end
        end

        unless table_exists?(:profile_rights)
            create_table :profile_rights do |t|
                t.references :profile, null: false, foreign_key: true
                t.string :resource, null: false # Le nom de la classe du modèle (ex: 'User')
                t.string :action, null: false # L'action (ex: 'create', 'update', etc.)
                t.boolean :authorized, default: true

                t.timestamps
            end
        end
    end
end
