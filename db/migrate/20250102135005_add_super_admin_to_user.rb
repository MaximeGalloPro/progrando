class AddSuperAdminToUser < ActiveRecord::Migration[7.0]
    def change
        add_column :users, :super_admin, :boolean, default: false unless column_exists?(:users, :super_admin)
    end
end
