class VisitTrackerService
  def initialize(link:, ip:, user_agent:, referer:)
    @link       = link
    @ip         = ip
    @user_agent = user_agent
    @referer    = referer
  end

  def call
    b   = Browser.new(@user_agent)
    geo = lookup_geo(@ip)

    Visit.create!(
      link:            @link,
      ip_address:      @ip,
      user_agent:      @user_agent,
      browser:         b.name,
      browser_version: b.full_version&.split(".")&.first,
      os:              b.platform.name,
      device_type:     device_type(b),
      country:         geo&.country,
      country_code:    geo&.country_code&.upcase&.first(2),
      city:            geo&.city,
      region:          geo&.region,
      referer:         clean_referer(@referer),
      bot:             b.bot?
    )
  end

  private

  def device_type(browser)
    return "bot"     if browser.bot?
    return "tablet"  if browser.device.tablet?
    return "mobile"  if browser.device.mobile?

    "desktop"
  end

  def lookup_geo(ip)
    return nil if ip.blank? || ip == "127.0.0.1" || ip.start_with?("192.168.", "10.", "172.")

    Geocoder.search(ip).first
  rescue StandardError
    nil
  end

  def clean_referer(referer)
    return nil if referer.blank?

    uri = URI.parse(referer)
    uri.host.present? ? "#{uri.scheme}://#{uri.host}" : nil
  rescue URI::InvalidURIError
    nil
  end
end
