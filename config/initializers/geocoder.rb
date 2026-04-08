Geocoder.configure(
  ip_lookup: :ipinfo_io,
  api_key:   ENV["IPINFO_TOKEN"],
  timeout:   3,
  cache:     Rails.cache,
  cache_prefix: "geocoder:"
)
