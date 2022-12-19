class CreateOrderDetails < ActiveRecord::Migration[5.2]
  def change
    create_table :order_details do |t|
      t.integer :order_id
      t.integer :recipe_id
      t.integer :quantity
      t.integer :current_price

      t.timestamps
    end
  end
end
