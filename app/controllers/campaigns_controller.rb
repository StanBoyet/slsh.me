class CampaignsController < ApplicationController
  before_action :set_campaign, only: %i[show destroy]

  def show
    @range = (params[:range] || "30d").to_s
    from = case @range
    when "7d"  then 7.days.ago
    when "90d" then 90.days.ago
    else            30.days.ago
    end

    @links = @campaign.links.not_archived.includes(:custom_domain).order(clicks_count: :desc).to_a
    @total_clicks = @links.sum(&:clicks_count)
    @total_links = @links.size

    link_ids = @links.map(&:id)

    if link_ids.any?
      scoped = Visit.where(link_id: link_ids).where(created_at: from..)
      @period_clicks = scoped.count
      @top_sources = scoped.where.not(referer: [ nil, "" ]).group(:referer).order("count_all DESC").limit(5).count
      @top_countries = scoped.group(:country).order("count_all DESC").limit(5).count
      @top_country = @top_countries.first
      @by_source = utm_source_breakdown(link_ids, from)
    else
      @period_clicks = 0
      @top_sources = {}
      @top_countries = {}
      @top_country = nil
      @by_source = []
    end
  end

  def create
    @campaign = Current.user.campaigns.build(campaign_params)

    if @campaign.save
      render json: { id: @campaign.id, name: @campaign.name, slug: @campaign.slug, color: @campaign.color }
    else
      render json: { errors: @campaign.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def destroy
    @campaign.links.update_all(campaign_id: nil)
    @campaign.destroy
    redirect_to links_path, notice: "Campaign deleted."
  end

  private

  def set_campaign
    @campaign = Current.user.campaigns.find(params[:id])
  end

  def campaign_params
    params.expect(campaign: [ :name, :slug, :color ])
  end

  # Breakdown clicks by utm_source extracted from original_url
  # Returns array of [source_label, click_count] sorted desc
  def utm_source_breakdown(link_ids, from)
    # Get clicks per link in the period
    clicks_per_link = Visit.where(link_id: link_ids, created_at: from..)
                           .group(:link_id).count

    # Map link_id -> utm_source from the original_url
    links_by_id = @links.index_by(&:id)
    by_source = Hash.new(0)

    clicks_per_link.each do |link_id, count|
      link = links_by_id[link_id]
      next unless link

      source = extract_utm_param(link.original_url, "utm_source") || "direct"
      by_source[source] += count
    end

    by_source.sort_by { |_, count| -count }
  end

  def extract_utm_param(url, param)
    URI.parse(url).query&.then { |q| URI.decode_www_form(q).to_h[param] }
  rescue URI::InvalidURIError
    nil
  end
end
