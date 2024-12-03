class ChangeColumnRoleToRoleId < ActiveRecord::Migration[7.0]
  def change
    remove_column :members, :role if column_exists?(:members, :role)
    add_column :members, :role_id, :integer unless column_exists?(:members, :role_id)
  end
end
