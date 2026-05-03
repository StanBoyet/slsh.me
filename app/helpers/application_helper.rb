module ApplicationHelper
  # Campaign colors map to design-system sticker palette + a hex for inline styles.
  CAMPAIGN_COLORS = {
    "orange"  => { hex: "#FB8B3C", sticker: "s-tangerine" }, # tangerine
    "blue"    => { hex: "#6FC4EE", sticker: "s-sky" },       # sky
    "emerald" => { hex: "#B6DE5B", sticker: "s-lime" },      # lime
    "violet"  => { hex: "#B5A0FB", sticker: "s-violet" },    # violet
    "rose"    => { hex: "#F49AC0", sticker: "s-pink" }       # pink
  }.freeze

  # Legacy class helpers preserved for views that haven't been ported.
  def campaign_bg_class(color)
    {
      "orange"  => "bg-tangerine",
      "blue"    => "bg-sky",
      "emerald" => "bg-lime",
      "violet"  => "bg-violet",
      "rose"    => "bg-pink"
    }[color] || "bg-ink-faint"
  end

  def campaign_ring_class(color)
    "" # rings deprecated in the new design
  end

  # Hex color for inline styling (chip dots, banner emblems, etc.)
  def campaign_hex(color)
    CAMPAIGN_COLORS.dig(color, :hex) || "#9A9389"
  end

  # Sticker class modifier for the campaign palette
  def campaign_sticker_class(color)
    CAMPAIGN_COLORS.dig(color, :sticker) || ""
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
