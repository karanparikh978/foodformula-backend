class CreateMastersFoodItems < ActiveRecord::Migration[5.2]
  def change
    create_table :masters_food_items do |t|
      t.string :name
      t.integer :restaurant_id
      t.integer :status_id
      t.integer :category_id
      t.string :ingredients
      t.integer :type
      t.integer :total_cooked_weight
      t.string :serving_description
      t.integer :per_serving_weight
      t.integer :per_serving_cost_price
      t.integer :per_serving_selling_price
      t.string :cooking_info
      t.string :allergies_info

      t.timestamps
    end
  end
end
