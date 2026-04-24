# A customer-configured hostname that serves short-link redirects. The user
# points a CNAME at the slsh.me server (91.98.29.147), and Caddy (fronting
# kamal-proxy) handles TLS via on-demand Let's Encrypt — the first HTTPS
# request triggers cert issuance. Caddy gates that issuance behind
# GET /domain_check?domain=<host> so random Host headers can't burn our
# ACME rate limit. See config/Caddyfile and config/deploy.yml.
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
