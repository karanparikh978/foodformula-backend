class OrderDetail < ApplicationRecord
    belongs_to :recipe, :class_name => "MastersFoodItem", foreign_key: :recipe_id
end
