module ApplicationHelper
  CAMPAIGN_COLOR_CLASSES = {
    "orange"  => { bg: "bg-orange-500", ring: "ring-orange-300" },
    "blue"    => { bg: "bg-blue-500",   ring: "ring-blue-300" },
    "emerald" => { bg: "bg-emerald-500", ring: "ring-emerald-300" },
    "violet"  => { bg: "bg-violet-500", ring: "ring-violet-300" },
    "rose"    => { bg: "bg-rose-500",   ring: "ring-rose-300" }
  }.freeze

  def campaign_bg_class(color)
    CAMPAIGN_COLOR_CLASSES.dig(color, :bg) || "bg-zinc-500"
  end

  def campaign_ring_class(color)
    CAMPAIGN_COLOR_CLASSES.dig(color, :ring) || "ring-zinc-300"
  end

  # Extract UTM parameters from a URL for display
  # Returns hash like { "source" => "twitter", "medium" => "social" }
  def extract_utm_display(url)
    query = URI.parse(url).query
    return {} unless query

    URI.decode_www_form(query)
      .select { |k, _| k.start_with?("utm_") }
      .map { |k, v| [ k.delete_prefix("utm_"), v ] }
      .to_h
  rescue URI::InvalidURIError
    {}
  end
end
