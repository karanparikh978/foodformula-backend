class AddOtherColumnsToMastersFoodItems < ActiveRecord::Migration[5.2]
  def change
    add_column :masters_food_items, :allergy_ids, :varchar
    add_column :masters_food_items, :meal_type_ids, :varchar
  end
end
