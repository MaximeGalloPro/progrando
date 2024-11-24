class CreateHikes < ActiveRecord::Migration[7.0]
    def change
        unless table_exists?(:hikes)
            create_table :hikes do |t|
                t.integer :number, null: false, index: { unique: true }
                t.integer :day, null: false
                t.integer :difficulty
                t.string :starting_point
                t.string :trail_name
                t.float :carpooling_cost
                t.float :distance_km
                t.float :elevation_gain
                t.string :openrunner_ref

                t.timestamps
            end
        end
    end
end