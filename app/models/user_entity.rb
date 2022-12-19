class UserEntity < ApplicationRecord
    belongs_to :master, :class_name => "MastersEntity", foreign_key: :entity_id
end
