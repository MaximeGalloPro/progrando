class CreateHikeHistories < ActiveRecord::Migration[7.0]
    def change
        unless table_exists?(:hike_histories)
        create_table :hike_histories do |t|
            t.date :hiking_date
            t.string :departure_time
            t.string :day_type
            t.integer :difficulty
            t.string :starting_point
            t.string :trail_name
            t.decimal :carpooling_cost, precision: 5, scale: 2
            t.decimal :distance_km, precision: 5, scale: 2
            t.integer :elevation_gain
            t.string :guide_name
            t.string :guide_phone
            t.integer :hike_number
            t.string :openrunner_ref
            t.string :openrunner_url

            t.timestamps
        end
        end

        add_index :hike_histories, :hike_number unless index_exists?(:hike_histories, :hike_number)
        add_index :hike_histories, [:hiking_date, :hike_number], unique: true unless index_exists?(:hike_histories, [:hiking_date, :hike_number], unique: true)
    end
end