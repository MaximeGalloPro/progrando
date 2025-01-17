class AddUniqueIndexToProfiles < ActiveRecord::Migration[7.0]
  def change
    add_index :profiles, [:name, :organisation_id], unique: true
  end
end