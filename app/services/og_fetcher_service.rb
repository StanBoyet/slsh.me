class OgFetcherService
  def initialize(url)
    @url = url
  end

  def call
    uri = URI.parse(@url)
    return {} unless uri.is_a?(URI::HTTP) || uri.is_a?(URI::HTTPS)

    response = Net::HTTP.start(uri.host, uri.port, use_ssl: uri.scheme == "https", open_timeout: 5, read_timeout: 5) do |http|
      http.get(uri.request_uri, "User-Agent" => "slsh.me/1.0 (OG Fetcher)")
    end

    return {} unless response.is_a?(Net::HTTPSuccess)

    doc = Nokogiri::HTML(response.body)

    {
      title: og_content(doc, "og:title") || doc.at_css("title")&.text&.strip,
      description: og_content(doc, "og:description") || og_content(doc, "description"),
      image: og_content(doc, "og:image")
    }.compact
  rescue StandardError
    {}
  end

  private

  def og_content(doc, property)
    tag = doc.at_css("meta[property='#{property}']") || doc.at_css("meta[name='#{property}']")
    value = tag&.[]("content")&.strip
    value.presence
  end
end
