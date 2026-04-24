class DomainChecksController < ApplicationController
  # Caddy queries this endpoint before asking Let's Encrypt for a cert for a
  # given hostname (on-demand TLS "ask" hook). 200 = go ahead, 404 = refuse.
  # Anything that isn't a registered custom domain must refuse, or a crawler
  # hitting the server with a random Host header could burn our LE rate limit.
  allow_unauthenticated_access
  skip_before_action :enforce_domain_routing

  # Cheap ceiling: Caddy will only hit this when a new host appears; normal
  # traffic should be near zero. Still cap it to prevent ACME-adjacent abuse.
  rate_limit to: 30, within: 1.minute, by: -> { request.remote_ip }, with: -> { head :too_many_requests }

  def show
    domain = params[:domain].to_s.strip.downcase

    if domain.present? && CustomDomain.exists?(domain: domain)
      head :ok
    else
      head :not_found
    end
  end
end
