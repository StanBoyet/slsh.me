class Visit < ApplicationRecord
  belongs_to :link

  after_create_commit :broadcast_to_analytics, :broadcast_clicks_update

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
      locals:  { visit: self, animate: true }
    )
  end

  def broadcast_clicks_update
    count = link.reload.clicks_count
    formatted = ActiveSupport::NumberHelper.number_to_delimited(count)

    # Update the per-link click count on the index page
    Turbo::StreamsChannel.broadcast_update_to(
      "user_#{link.user_id}_clicks",
      target: "link_#{link_id}_clicks",
      html: formatted
    )

    # Update total clicks in the header
    total = link.user.links.not_archived.sum(:clicks_count)
    Turbo::StreamsChannel.broadcast_update_to(
      "user_#{link.user_id}_clicks",
      target: "total_clicks",
      html: ActiveSupport::NumberHelper.number_to_delimited(total)
    )
  end
end
