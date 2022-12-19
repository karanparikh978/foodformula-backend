class MastersFoodItem < ApplicationRecord

    default_scope {order('sort_by asc')}

    belongs_to :category, :class_name => 'RestaurantCategory', foreign_key: :category_id
    has_many :prices, :class_name => 'FoodItemPrice', foreign_key: :food_item_id
    has_many :aliases, :class_name => 'FoodItemAlias', foreign_key: :food_item_id
    has_many :images, -> { where(entity_type: ENTITY_TYPE_FOOD_ITEM) }, class_name: 'EntityImage', foreign_key: :entity_type_id

end
