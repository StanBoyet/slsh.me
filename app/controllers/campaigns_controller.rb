class CampaignsController < ApplicationController
  before_action :set_campaign, only: %i[show edit update destroy update_channels]

  def new
    @campaign = Current.user.campaigns.build(color: "orange")
  end

  def show
    @links = @campaign.links.not_archived.includes(:custom_domain).order(clicks_count: :desc).to_a
    @total_clicks = @links.sum(&:clicks_count)
    @total_links  = @links.size

    link_ids = @links.map(&:id)

    if link_ids.any?
      scoped = Visit.where(link_id: link_ids)
      @top_sources   = scoped.where.not(referer: [ nil, "" ]).group(:referer).order("count_all DESC").limit(5).count
      @top_countries = scoped.group(:country).order("count_all DESC").limit(5).count
      @top_country   = @top_countries.first
      @by_source     = utm_source_breakdown(link_ids)
      @recent_visits = scoped.recent.limit(8).to_a
    else
      @top_sources   = {}
      @top_countries = {}
      @top_country   = nil
      @by_source     = []
      @recent_visits = []
    end

    @goal       = @campaign.goal_progress(@total_clicks)
    @pace_delta = @campaign.pace_delta(@total_clicks)
    @clicks_by_day, @target_by_day = sparkline_series(link_ids)
  end

  def create
    @campaign = Current.user.campaigns.build(create_params)

    respond_to do |format|
      if @campaign.save
        PostHog.capture(distinct_id: Current.user.posthog_distinct_id, event: "campaign_created", properties: { name: @campaign.name })
        format.json { render json: { id: @campaign.id, name: @campaign.name, slug: @campaign.slug, color: @campaign.color } }
        format.html { redirect_to campaign_path(@campaign), notice: "Campaign created." }
      else
        format.json { render json: { errors: @campaign.errors.full_messages }, status: :unprocessable_entity }
        format.html { render :new, status: :unprocessable_entity }
      end
    end
  end

  def edit
  end

  def update
    @campaign.og_image.purge if params.dig(:campaign, :remove_og_image) == "1"

    if @campaign.update(campaign_params)
      PostHog.capture(distinct_id: Current.user.posthog_distinct_id, event: "campaign_updated", properties: { slug: @campaign.slug })
      redirect_to campaign_path(@campaign), notice: "Campaign updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def update_channels
    if @campaign.destination_url.blank? && params[:destination_url].blank?
      return render(json: { error: "Destination URL is required before saving channels." }, status: :unprocessable_entity)
    end

    rows = Array(params[:channels]).map(&:to_unsafe_h)
    saved = []
    errors = []

    Campaign.transaction do
      @campaign.update!(destination_url: params[:destination_url]) if params[:destination_url].present?

      rows.each do |row|
        if row["_destroy"] == "1" || row["_destroy"] == true
          link = @campaign.links.find_by(id: row["id"]) if row["id"].present?
          link&.destroy
          next
        end

        attrs = link_attrs_from_row(row)
        link  = row["id"].present? ? @campaign.links.find(row["id"]) : @campaign.links.build(user: Current.user)

        if link.update(attrs)
          saved << link
        else
          errors << { row: row["client_id"], messages: link.errors.full_messages }
        end
      end

      raise ActiveRecord::Rollback if errors.any?
    end

    if errors.any?
      render json: { errors: errors }, status: :unprocessable_entity
    else
      render json: {
        destination_url: @campaign.destination_url,
        links: saved.map { |l| serialize_link(l) }
      }
    end
  end

  def fetch_og
    url = params[:url].to_s.strip
    return render(json: { error: "No URL" }, status: :unprocessable_entity) if url.blank?

    render json: OgFetcherService.new(url).call
  end

  def destroy
    PostHog.capture(distinct_id: Current.user.posthog_distinct_id, event: "campaign_deleted", properties: { name: @campaign.name })
    @campaign.links.update_all(campaign_id: nil)
    @campaign.destroy
    redirect_to links_path, notice: "Campaign deleted."
  end

  private

  def set_campaign
    @campaign = Current.user.campaigns.find(params[:id])
  end

  def create_params
    params.expect(campaign: [ :name, :slug, :color ])
  end

  def campaign_params
    params.expect(
      campaign: [
        :name, :slug, :color,
        :destination_url, :title, :description, :og_image,
        :goal_clicks, :starts_at, :ends_at
      ]
    )
  end

  def link_attrs_from_row(row)
    utm_source = row["utm_source"].to_s.strip
    utm_medium = row["utm_medium"].to_s.strip

    {
      original_url: assemble_url(@campaign.destination_url, {
        "utm_source"   => utm_source.presence,
        "utm_medium"   => utm_medium.presence,
        "utm_campaign" => @campaign.slug
      }),
      slug:              row["slug"].to_s.strip.presence,
      custom_domain_id:  row["custom_domain_id"].presence
    }.compact
  end

  def assemble_url(base, utm_params)
    uri = URI.parse(base)
    existing = URI.decode_www_form(uri.query.to_s).reject { |k, _| k.start_with?("utm_") }
    merged   = existing + utm_params.compact_blank.map { |k, v| [ k, v ] }
    uri.query = merged.any? ? URI.encode_www_form(merged) : nil
    uri.to_s
  rescue URI::InvalidURIError
    base
  end

  def serialize_link(link)
    {
      id:               link.id,
      slug:             link.slug,
      short_url:        link.short_url,
      clicks_count:     link.clicks_count,
      utm_source:       extract_utm_display(link.original_url)["source"],
      utm_medium:       extract_utm_display(link.original_url)["medium"]
    }
  end

  def utm_source_breakdown(link_ids)
    clicks_per_link = Visit.where(link_id: link_ids).group(:link_id).count
    links_by_id     = @links.index_by(&:id)
    by_source       = Hash.new(0)

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

  def extract_utm_display(url)
    helpers.extract_utm_display(url)
  end

  def sparkline_series(link_ids)
    return [ {}, {} ] if link_ids.empty? || @campaign.ends_at.blank? || @campaign.goal_clicks.blank?

    starts = @campaign.effective_starts_at.to_date
    ends   = @campaign.ends_at.to_date
    return [ {}, {} ] if ends <= starts

    actual = Visit.where(link_id: link_ids, created_at: starts..(ends + 1.day))
                  .group_by_day(:created_at, range: starts..ends).count

    days        = (starts..ends).to_a
    per_day_avg = @campaign.goal_clicks.to_f / days.size
    cumulative  = 0
    cumulative_actual = 0

    target_series = days.each_with_object({}) do |d, h|
      cumulative += per_day_avg
      h[d] = cumulative.round
    end

    actual_series = days.each_with_object({}) do |d, h|
      cumulative_actual += actual[d].to_i
      h[d] = cumulative_actual
    end

    [ actual_series, target_series ]
  end
end
