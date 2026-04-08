class Link < ApplicationRecord
  has_secure_password :password, validations: false

  belongs_to :user
  has_many :visits, dependent: :destroy

  RESERVED_SLUGS = %w[session sessions password passwords link links user users
                       admin dashboard analytics health assets login logout register signup].freeze
  SLUG_FORMAT = /\A[a-zA-Z0-9_-]+\z/

  validates :original_url, presence: true
  validate :original_url_is_valid
  validates :slug, presence: true,
                   uniqueness: { case_sensitive: false },
                   format: { with: SLUG_FORMAT, message: "only allows letters, numbers, hyphens and underscores" },
                   exclusion: { in: RESERVED_SLUGS, message: "is reserved" }
  validates :max_clicks, numericality: { greater_than: 0, allow_nil: true }

  before_validation :assign_slug, on: :create

  scope :active,   -> { where(active: true) }
  scope :inactive, -> { where(active: false) }
  scope :expired,  -> { where("expires_at IS NOT NULL AND expires_at < ?", Time.current) }
  scope :alive,    -> { active.where("expires_at IS NULL OR expires_at >= ?", Time.current) }

  def expired?
    (expires_at.present? && expires_at < Time.current) ||
      (max_clicks.present? && clicks_count >= max_clicks)
  end

  def password_protected?
    password_digest.present?
  end

  def og_title
    title.presence || "Shared link"
  end

  def og_description
    description.presence || original_url
  end

  private

  def assign_slug
    self.slug = SlugGenerator.generate if slug.blank?
  end

  def original_url_is_valid
    return if original_url.blank?

    uri = URI.parse(original_url)
    unless uri.is_a?(URI::HTTP) || uri.is_a?(URI::HTTPS)
      errors.add(:original_url, "must be a valid HTTP or HTTPS URL")
    end
  rescue URI::InvalidURIError
    errors.add(:original_url, "is not a valid URL")
  end
end
