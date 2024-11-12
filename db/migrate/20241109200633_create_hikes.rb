class CreateHikes < ActiveRecord::Migration[7.0]
    def change
        unless table_exists?(:hikes)
            create_table :hikes do |t|
                t.integer :number, null: false, index: { unique: true }
                t.integer :day, null: false
                t.integer :difficulty
                t.string :starting_point
                t.string :trail_name
                t.integer :carpooling_cost
                t.decimal :distance_km, precision: 5, scale: 2
                t.integer :elevation_gain
                t.string :openrunner_ref
                t.string :openrunner_url

                t.timestamps
            end
        end
    end
end