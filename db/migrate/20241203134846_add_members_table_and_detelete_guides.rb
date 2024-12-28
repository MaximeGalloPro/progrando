class AddMembersTableAndDeteleteGuides < ActiveRecord::Migration[7.0]
    def change
        unless table_exists?(:members)
            create_table :members do |t|
                t.string :name
                t.string :email
                t.string :phone
                t.integer :role
                t.timestamps
            end
        end

        unless table_exists?(:roles)
            create_table :roles do |t|
                t.string :name
                t.timestamps
            end
        end
        role = Role.find_by(name: 'guide')
        role = Role.create(name: 'guide') unless role.present?
    end
end
