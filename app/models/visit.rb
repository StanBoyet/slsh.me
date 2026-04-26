class Visit < ApplicationRecord
  belongs_to :link

  after_create_commit :broadcast_to_analytics, :broadcast_clicks_update, :broadcast_to_campaign

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
    count, user_id = Link.where(id: link_id).pick(:clicks_count, :user_id)
    return unless count

    stream = "user_#{user_id}_clicks"
    formatted = ActiveSupport::NumberHelper.number_to_delimited(count)

    Turbo::StreamsChannel.broadcast_update_to(stream, target: "link_#{link_id}_clicks", html: formatted)

    total = Link.where(user_id: user_id, archived: false).sum(:clicks_count)
    Turbo::StreamsChannel.broadcast_update_to(stream, target: "total_clicks",
      html: ActiveSupport::NumberHelper.number_to_delimited(total))
  end

  def broadcast_to_campaign
    campaign_id = Link.where(id: link_id).pick(:campaign_id)
    return unless campaign_id

    stream = "campaign_#{campaign_id}_visits"

    broadcast_prepend_to(stream,
      target:  "campaign-live-feed",
      partial: "campaigns/live_visit",
      locals:  { visit: self, animate: true })

    total = Link.where(campaign_id: campaign_id).sum(:clicks_count)
    Turbo::StreamsChannel.broadcast_update_to(stream,
      target: "campaign_#{campaign_id}_total_clicks",
      html:   ActiveSupport::NumberHelper.number_to_delimited(total))
  end
end
