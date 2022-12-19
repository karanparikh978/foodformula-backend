class ChangeColumnNameTypeInMastersFoodItems < ActiveRecord::Migration[5.2]
  def change
    rename_column :masters_food_items, :type, :recipe_type
  end
end
