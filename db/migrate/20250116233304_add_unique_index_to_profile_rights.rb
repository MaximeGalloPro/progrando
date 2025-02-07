class AddUniqueIndexToProfileRights < ActiveRecord::Migration[7.0]
  def change
    add_index :profile_rights, [:profile_id, :resource, :action], unique: true
  end
end