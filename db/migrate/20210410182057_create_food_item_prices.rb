class CreateFoodItemPrices < ActiveRecord::Migration[5.2]
  def change
    create_table :food_item_prices do |t|
      t.integer :food_item_id
      t.integer :entity_id
      t.integer :price

      t.timestamps
    end
  end
end
