class Visit < ApplicationRecord
  belongs_to :link

  scope :human,   -> { where(bot: false) }
  scope :bots,    -> { where(bot: true) }
  scope :recent,  -> { order(created_at: :desc) }
  scope :in_range, ->(from, to) { where(created_at: from..to) }
end
