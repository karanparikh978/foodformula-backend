class CreateFoodItemAliases < ActiveRecord::Migration[5.2]
  def change
    create_table :food_item_aliases do |t|
      t.integer :food_item_id
      t.integer :language_id
      t.string :alias

      t.timestamps
    end
  end
end
