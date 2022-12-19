class CreateOrders < ActiveRecord::Migration[5.2]
  def change
    create_table :orders do |t|
      t.string :name
      t.bigint :mobile_no
      t.string :email
      t.datetime :order_time
      t.integer :restaurant_id
      t.integer :status_id
      t.string :instruction

      t.timestamps
    end
  end
end
