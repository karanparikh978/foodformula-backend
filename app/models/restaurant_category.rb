class RestaurantCategory < ApplicationRecord
    has_many :food_items, :class_name => 'MastersFoodItem', foreign_key: :category_id
end
