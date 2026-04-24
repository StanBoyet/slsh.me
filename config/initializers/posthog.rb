# PostHog analytics + error tracking
#
# posthog-rails provides:
# - Automatic exception capture for unhandled controller errors
# - ActiveJob instrumentation for background job failures
# - User context detection from current_user
# - Rails.error integration for rescued exceptions
if ENV["POSTHOG_API_KEY"].present?
  PostHog.init do |config|
    config.api_key = ENV["POSTHOG_API_KEY"]
    config.host = ENV["POSTHOG_HOST"] if ENV["POSTHOG_HOST"].present?
  end

  PostHog::Rails.configure do |config|
    config.auto_capture_exceptions = true
    config.report_rescued_exceptions = true
    config.auto_instrument_active_job = true
    config.capture_user_context = true
    config.current_user_method = :current_user
    config.user_id_method = :posthog_distinct_id
  end
else
  # Test env and local dev run without a key. Controllers call PostHog.capture
  # and PostHog.identify directly; stub both to no-ops so we don't have to
  # wrap every callsite.
  module PostHog
    def self.capture(*); end
    def self.identify(*); end
  end
end
