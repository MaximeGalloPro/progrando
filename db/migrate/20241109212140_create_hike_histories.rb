class CreateHikeHistories < ActiveRecord::Migration[7.0]
    def change
        unless table_exists?(:hike_histories)
            create_table :hike_histories do |t|
                t.date :hiking_date
                t.string :departure_time
                t.string :day_type
                t.decimal :carpooling_cost, precision: 5, scale: 2
                t.integer :guide_id
                t.integer :hike_number
                t.string :openrunner_ref

                t.timestamps
            end
        end

        add_index :hike_histories, :hike_number unless index_exists?(:hike_histories, :hike_number)
        add_index :hike_histories, [:hiking_date, :hike_number], unique: true unless index_exists?(:hike_histories, [:hiking_date, :hike_number], unique: true)
    end
end