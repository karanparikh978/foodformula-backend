class Order < ApplicationRecord
    has_many :order_details, :class_name => 'OrderDetail', foreign_key: :order_id
end
