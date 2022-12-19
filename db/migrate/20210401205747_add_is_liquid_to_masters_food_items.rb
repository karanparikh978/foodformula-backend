class AddIsLiquidToMastersFoodItems < ActiveRecord::Migration[5.2]
  def change
    add_column :masters_food_items, :is_liquid, :boolean
  end
end
