class ChangeColumnGuideIdToMemberInHikeHistories < ActiveRecord::Migration[7.0]
    def change
        if column_exists? :hike_histories, :guide_id
            rename_column :hike_histories, :guide_id, :member_id if column_exists? :hike_histories, :guide_id
        else
            add_column :hike_histories, :member_id, :integer unless column_exists? :hike_histories, :member_id
        end
    end
end
