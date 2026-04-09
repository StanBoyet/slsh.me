class CustomDomain < ApplicationRecord
  belongs_to :user
  has_many :links, dependent: :nullify

  DOMAIN_FORMAT = /\A[a-z0-9]([a-z0-9-]*[a-z0-9])?(\.[a-z0-9]([a-z0-9-]*[a-z0-9])?)+\z/i

  validates :domain, presence: true,
                     uniqueness: { case_sensitive: false },
                     format: { with: DOMAIN_FORMAT, message: "must be a valid hostname" }

  normalizes :domain, with: ->(d) { d.strip.downcase }

  def archive_links!
    links.find_each do |link|
      link.update!(archived: true, active: false, custom_domain: nil)
    end
  end
end
