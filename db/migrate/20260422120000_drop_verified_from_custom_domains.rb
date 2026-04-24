class DropVerifiedFromCustomDomains < ActiveRecord::Migration[8.1]
  # The `verified` flag was driven by polling the Fly.io certificates API.
  # With Caddy on-demand TLS, there's no cert-verification step the user
  # explicitly triggers — the cert is fetched from Let's Encrypt the first
  # time the domain is visited over HTTPS. The column has no meaning now.
  def change
    remove_column :custom_domains, :verified, :boolean, default: false, null: false
  end
end
