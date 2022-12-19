class UserLanguage < ApplicationRecord
    belongs_to :master, :class_name => "MastersLanguage", foreign_key: :language_id
end
