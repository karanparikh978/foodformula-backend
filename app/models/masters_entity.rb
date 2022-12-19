class MastersEntity < ApplicationRecord

    scope :published, lambda { where(status_id: CONTENT_STATUS_PUBLISHED) }

end
