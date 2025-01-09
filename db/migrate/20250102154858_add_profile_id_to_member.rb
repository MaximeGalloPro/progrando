class AddProfileIdToMember < ActiveRecord::Migration[7.0]
    def change
        add_column :members, :profile_id, :integer unless column_exists? :members, :profile_id
    end
end