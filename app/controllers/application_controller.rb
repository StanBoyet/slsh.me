class ApplicationController < ActionController::Base
  include Authentication
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  # Changes to the importmap will invalidate the etag for HTML responses
  stale_when_importmap_changes

  prepend_before_action :enforce_domain_routing

  helper_method :custom_domain_request?, :app_url, :current_user

  private

  # Alias for posthog-rails user context detection
  def current_user
    Current.user
  end

  def primary_host
    ENV.fetch("APP_HOST", "localhost")
  end

  def app_subdomain_host
    host = primary_host
    return host if host == "localhost" || host.start_with?("127.")
    "app.#{host}"
  end

  def custom_domain_request?
    return false unless ENV["APP_HOST"].present?

    host = request.host
    host != primary_host && host != app_subdomain_host
  end

  def on_primary_domain?
    return true unless ENV["APP_HOST"].present?

    request.host == primary_host
  end

  def on_app_subdomain?
    return true unless ENV["APP_HOST"].present?

    request.host == app_subdomain_host
  end

  def enforce_domain_routing
    return unless ENV["APP_HOST"].present?

    case controller_name
    when "pages"
      # Landing page: only on primary domain. App subdomain root → redirect to dashboard.
      redirect_to app_url("/links"), allow_other_host: true if on_app_subdomain?
    when "redirects", "health"
      # Redirects work on primary domain and custom domains, not app subdomain
      redirect_to "https://#{primary_host}#{request.fullpath}", allow_other_host: true if on_app_subdomain?
    else
      if custom_domain_request?
        # Custom domain hitting app routes → go to primary
        redirect_to "https://#{primary_host}", allow_other_host: true
      elsif on_primary_domain?
        # App routes on primary domain → go to app subdomain
        redirect_to "https://#{app_subdomain_host}#{request.fullpath}", allow_other_host: true
      end
    end
  end

  # Helper to generate URLs on the app subdomain
  def app_url(path = "/")
    if ENV["APP_HOST"].present?
      "https://#{app_subdomain_host}#{path}"
    else
      path
    end
  end
end
