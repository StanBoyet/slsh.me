class Link < ApplicationRecord
  has_secure_password :password, validations: false

  belongs_to :user
  belongs_to :custom_domain, optional: true
  has_many :visits, dependent: :destroy
  has_one_attached :og_image

  RESERVED_SLUGS = %w[session sessions password passwords link links user users
                       admin dashboard analytics health assets login logout register signup
                       custom_domains].freeze
  SLUG_FORMAT = /\A[a-zA-Z0-9_-]+\z/

  validates :original_url, presence: true
  validate :original_url_is_valid
  validates :slug, presence: true,
                   format: { with: SLUG_FORMAT, message: "only allows letters, numbers, hyphens and underscores" },
                   exclusion: { in: RESERVED_SLUGS, message: "is reserved" }
  validate :slug_unique_within_scope
  validate :domain_immutable, on: :update
  validates :max_clicks, numericality: { greater_than: 0, allow_nil: true }

  before_validation :assign_slug, on: :create

  scope :active,       -> { where(active: true) }
  scope :inactive,     -> { where(active: false) }
  scope :archived,     -> { where(archived: true) }
  scope :not_archived, -> { where(archived: false) }
  scope :expired,      -> { where("expires_at IS NOT NULL AND expires_at < ?", Time.current) }
  scope :alive,        -> { active.not_archived.where("expires_at IS NULL OR expires_at >= ?", Time.current) }

  def expired?
    (expires_at.present? && expires_at < Time.current) ||
      (max_clicks.present? && clicks_count >= max_clicks)
  end

  def expires_soon?
    expires_at.present? && expires_at > Time.current && expires_at < 7.days.from_now
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

  def og_image_url
    return unless og_image.attached?

    Rails.application.routes.url_helpers.rails_blob_url(og_image, host: ENV.fetch("APP_HOST", "localhost"))
  end

  def domain_label
    custom_domain&.domain || ENV.fetch("APP_HOST", "slsh.me")
  end

  def short_url
    if custom_domain.present?
      "https://#{domain_label}/#{slug}"
    else
      "https://#{domain_label}/l/#{slug}"
    end
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

  def domain_immutable
    return unless custom_domain_id_changed?
    return if archived? # allow clearing domain_id when archiving

    errors.add(:custom_domain_id, "cannot be changed after creation")
  end

  def slug_unique_within_scope
    return if slug.blank? || archived?

    scope = Link.not_archived.where(custom_domain_id: custom_domain_id).where(slug: slug)
    scope = scope.where.not(id: id) if persisted?
    errors.add(:slug, "has already been taken") if scope.exists?
  end
end
