class AddMealTypesInfoToMastersFoodItems < ActiveRecord::Migration[5.2]
  def change
    add_column :masters_food_items, :meal_types_info, :varchar
  end
end
