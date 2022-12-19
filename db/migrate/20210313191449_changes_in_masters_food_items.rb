class ChangesInMastersFoodItems < ActiveRecord::Migration[5.2]
  def change
    add_column :masters_food_items, :used_as_ingredient, :boolean
    add_column :masters_food_items, :expiry_date, :varchar
    rename_column :masters_food_items, :ingredients, :ingredients_info
  end
end
