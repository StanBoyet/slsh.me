class Campaign < ApplicationRecord
  COLORS = %w[orange blue emerald violet rose].freeze

  belongs_to :user
  has_many :links, dependent: :nullify
  has_one_attached :og_image

  validates :name, presence: true
  validates :slug, presence: true,
                   format: { with: /\A[a-z0-9_-]+\z/, message: "only allows lowercase letters, numbers, hyphens and underscores" },
                   uniqueness: { scope: :user_id }
  validates :color, inclusion: { in: COLORS }
  validates :goal_clicks, numericality: { greater_than: 0, allow_nil: true }
  validate  :destination_url_is_valid
  validate  :ends_at_after_starts_at

  before_validation :generate_slug, on: :create

  scope :with_clicks_count, -> {
    left_joins(:links)
      .select("campaigns.*, COALESCE(SUM(links.clicks_count), 0) AS computed_clicks_count")
      .group("campaigns.id")
  }

  def computed_clicks_count
    attributes["computed_clicks_count"]&.to_i || links.sum(:clicks_count)
  end

  def og_title
    title.presence || name
  end

  def og_description
    description.presence || destination_url.presence || "Campaign by #{user.email_address}"
  end

  def og_image_url
    return unless og_image.attached?

    Rails.application.routes.url_helpers.rails_blob_url(og_image, host: ENV.fetch("APP_HOST", "localhost"))
  end

  def effective_starts_at
    starts_at || created_at || Time.current
  end

  # Returns { clicks:, target:, percent: } or nil when no goal set.
  def goal_progress(actual_clicks)
    return nil if goal_clicks.blank? || goal_clicks <= 0

    percent = ((actual_clicks.to_f / goal_clicks) * 100).clamp(0, 100).round
    { clicks: actual_clicks, target: goal_clicks, percent: percent }
  end

  # Positive => ahead of straight-line target. Negative => behind. Nil when math undefined.
  def pace_delta(actual_clicks)
    return nil if goal_clicks.blank? || goal_clicks <= 0 || ends_at.blank?

    total = (ends_at - effective_starts_at).to_f
    return nil if total <= 0

    elapsed = ([ Time.current, ends_at ].min - effective_starts_at).to_f.clamp(0, total)
    expected = goal_clicks * (elapsed / total)
    (actual_clicks - expected).round
  end

  private

  def generate_slug
    return if slug.present? || name.blank?

    self.slug = name.parameterize
  end

  def destination_url_is_valid
    return if destination_url.blank?

    uri = URI.parse(destination_url)
    unless uri.is_a?(URI::HTTP) || uri.is_a?(URI::HTTPS)
      errors.add(:destination_url, "must be a valid HTTP or HTTPS URL")
    end
  rescue URI::InvalidURIError
    errors.add(:destination_url, "is not a valid URL")
  end

  def ends_at_after_starts_at
    return if ends_at.blank? || effective_starts_at.blank?
    return if ends_at > effective_starts_at

    errors.add(:ends_at, "must be after the start date")
  end
end
