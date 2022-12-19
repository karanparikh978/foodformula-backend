class AddSortByToMastersFoodItems < ActiveRecord::Migration[5.2]
  def change
    add_column :masters_food_items, :sort_by, :integer
  end
end
