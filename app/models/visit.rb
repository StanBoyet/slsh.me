class Visit < ApplicationRecord
  belongs_to :link

  after_create_commit :broadcast_to_analytics, unless: :bot?

  scope :human,    -> { where(bot: false) }
  scope :bots,     -> { where(bot: true) }
  scope :recent,   -> { order(created_at: :desc) }
  scope :in_range, ->(from, to) { where(created_at: from..to) }

  private

  def broadcast_to_analytics
    broadcast_prepend_to(
      "link_#{link_id}_visits",
      target:  "visits-table-body",
      partial: "links/visit_row",
      locals:  { visit: self }
    )
  end
end
