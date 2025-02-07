class CreateOrganisationAccessRequests < ActiveRecord::Migration[7.0]
    def change
        create_table :organisation_access_requests do |t|
            t.integer :user_id
            t.integer :organisation_id
            t.text :message
            t.string :role
            t.string :status
            t.text :admin_response
            t.integer :processed_by_id
            t.datetime :processed_at

            t.timestamps
        end
    end
end
