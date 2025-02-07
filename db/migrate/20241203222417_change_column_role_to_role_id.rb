class ChangeColumnRoleToRoleId < ActiveRecord::Migration[7.0]
    def change
        if column_exists? :members, :role
            rename_column :members, :role, :role_id
        elsif !column_exists? :members, :role_id
            add_column :members, :role_id, :integer
        end
    end
end
