class ApplicationController < ActionController::Base
  include Authentication
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  # Changes to the importmap will invalidate the etag for HTML responses
  stale_when_importmap_changes

  prepend_before_action :reject_custom_domain_for_app_routes

  helper_method :redirect_url, :custom_domain_request?

  def redirect_url(slug)
    "#{request.base_url}/#{slug}"
  end

  private

  def custom_domain_request?
    return false unless ENV["APP_HOST"].present?

    request.host != ENV["APP_HOST"]
  end

  def reject_custom_domain_for_app_routes
    return unless custom_domain_request?
    return if controller_name == "redirects"
    return if controller_name == "health"

    redirect_to "https://#{ENV.fetch('APP_HOST', 'slsh.me')}", allow_other_host: true
  end
end
