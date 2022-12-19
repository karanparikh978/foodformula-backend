class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

    before_create :update_api_key,:update_menu_key
    has_many :categories, :class_name => 'RestaurantCategory', foreign_key: :restaurant_id
    has_many :entities, :class_name => 'UserEntity', foreign_key: :user_id
    has_many :languages, :class_name => 'UserLanguage', foreign_key: :user_id
    has_one :published_logo, -> { where(entity_type: ENTITY_TYPE_LOGO,status_id: CONTENT_STATUS_PUBLISHED) }, class_name: 'EntityImage', foreign_key: :entity_type_id
    has_one :published_hr_logo, -> { where(entity_type: ENTITY_TYPE_HORIZONTAL_LOGO,status_id: CONTENT_STATUS_PUBLISHED) }, class_name: 'EntityImage', foreign_key: :entity_type_id
    has_many :banner_images, -> { where(entity_type: ENTITY_TYPE_BANNER_IMAGE,status_id: CONTENT_STATUS_PUBLISHED) }, class_name: 'EntityImage', foreign_key: :entity_type_id


    def update_api_key
      self.api_key = 32.times.map { [*'A'..'Z', *'a'..'z', *'0'..'9'].sample }.join
    end

    def update_menu_key
      self.menu_key = 32.times.map { [*'A'..'Z', *'a'..'z', *'0'..'9'].sample }.join
    end


end
