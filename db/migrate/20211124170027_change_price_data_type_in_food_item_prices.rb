class ChangePriceDataTypeInFoodItemPrices < ActiveRecord::Migration[5.2]
  def change
    change_column :food_item_prices, :price, :float
  end
end
