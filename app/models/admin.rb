class Admin < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  before_create :update_api_key



  def update_api_key
    self.api_key = 32.times.map { [*'A'..'Z', *'a'..'z', *'0'..'9'].sample }.join
  end



end
