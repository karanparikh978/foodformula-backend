class AddIsJainToMastersFoodItems < ActiveRecord::Migration[5.2]
  def change
    add_column :masters_food_items, :is_jain, :boolean
  end
end
