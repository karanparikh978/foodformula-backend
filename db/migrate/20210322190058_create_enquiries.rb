class CreateEnquiries < ActiveRecord::Migration[5.2]
  def change
    create_table :enquiries do |t|
      t.string :name
      t.string :email
      t.bigint :mobile_no
      t.string :city
      t.integer :status_id

      t.timestamps
    end
  end
end
