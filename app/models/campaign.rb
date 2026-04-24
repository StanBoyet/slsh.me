class Campaign < ApplicationRecord
  COLORS = %w[orange blue emerald violet rose].freeze

  belongs_to :user
  has_many :links, dependent: :nullify

  validates :name, presence: true
  validates :slug, presence: true,
                   format: { with: /\A[a-z0-9_-]+\z/, message: "only allows lowercase letters, numbers, hyphens and underscores" },
                   uniqueness: { scope: :user_id }
  validates :color, inclusion: { in: COLORS }

  before_validation :generate_slug, on: :create

  # Aggregate clicks from links without N+1 — use on collections:
  #   Campaign.with_clicks_count => each campaign has #computed_clicks_count
  scope :with_clicks_count, -> {
    left_joins(:links)
      .select("campaigns.*, COALESCE(SUM(links.clicks_count), 0) AS computed_clicks_count")
      .group("campaigns.id")
  }

  def computed_clicks_count
    attributes["computed_clicks_count"]&.to_i || links.sum(:clicks_count)
  end

  private

  def generate_slug
    return if slug.present? || name.blank?

    self.slug = name.parameterize
  end
end
