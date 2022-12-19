class FoodItemAlias < ApplicationRecord
    belongs_to :master_language, :class_name => "MastersLanguage", foreign_key: :language_id
end
