module CampaignsHelper
  CHANNEL_REGISTRY = {
    "meta"        => { label: "Meta",        icon: "📷", medium: "social", bg: "bg-blue-100 dark:bg-blue-500/15",     fg: "text-blue-600" },
    "linkedin"    => { label: "LinkedIn",    icon: "in", medium: "social", bg: "bg-sky-100 dark:bg-sky-500/15",       fg: "text-sky-600" },
    "newsletter"  => { label: "Newsletter",  icon: "✉",  medium: "email",  bg: "bg-amber-100 dark:bg-amber-500/15",   fg: "text-amber-600" },
    "twitter"     => { label: "Twitter / X", icon: "𝕏", medium: "social", bg: "bg-zinc-100 dark:bg-zinc-700/40",     fg: "text-zinc-700 dark:text-zinc-200" },
    "instagram"   => { label: "Instagram",   icon: "📷", medium: "social", bg: "bg-pink-100 dark:bg-pink-500/15",     fg: "text-pink-500" },
    "slack"       => { label: "Slack",       icon: "⌘",  medium: "dm",     bg: "bg-indigo-100 dark:bg-indigo-500/15", fg: "text-indigo-500" },
    "tiktok"      => { label: "TikTok",      icon: "♪",  medium: "social", bg: "bg-zinc-100 dark:bg-zinc-700/40",     fg: "text-zinc-700 dark:text-zinc-200" },
    "facebook"    => { label: "Facebook",    icon: "f",  medium: "social", bg: "bg-blue-100 dark:bg-blue-500/15",     fg: "text-blue-600" },
    "reddit"      => { label: "Reddit",      icon: "®",  medium: "social", bg: "bg-orange-100 dark:bg-orange-500/15", fg: "text-orange-600" },
    "github"      => { label: "GitHub",      icon: "gh", medium: "social", bg: "bg-zinc-100 dark:bg-zinc-700/40",     fg: "text-zinc-800 dark:text-zinc-100" }
  }.freeze

  DEFAULT_CHANNEL = { label: "Custom", icon: "•", medium: nil,
                      bg: "bg-zinc-100", fg: "text-zinc-600" }.freeze

  PRESEED_CHANNELS = %w[meta linkedin newsletter].freeze

  def channel_for(utm_source)
    CHANNEL_REGISTRY[utm_source.to_s] || DEFAULT_CHANNEL.merge(label: utm_source.to_s.presence ||"Custom")
  end

  # JSON map exposed to the channel_matrix Stimulus controller for utm_source -> medium presets.
  def channel_registry_json
    CHANNEL_REGISTRY.transform_values { |v| { label: v[:label], medium: v[:medium] } }.to_json
  end
end
