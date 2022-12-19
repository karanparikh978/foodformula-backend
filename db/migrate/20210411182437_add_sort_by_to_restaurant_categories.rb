class AddSortByToRestaurantCategories < ActiveRecord::Migration[5.2]
  def change
    add_column :restaurant_categories, :sort_by, :integer
  end
end
