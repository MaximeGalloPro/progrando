class AddTableUserMembers < ActiveRecord::Migration[7.0]
    def change
        unless table_exists?(:user_members)
            create_table :user_members do |t|
                t.integer :user_id
                t.integer :member_id
                t.timestamps
            end
        end
    end
end
