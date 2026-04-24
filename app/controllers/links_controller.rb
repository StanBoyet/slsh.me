class LinksController < ApplicationController
  before_action :set_link, only: %i[edit update destroy analytics qr]

  def index
    @filter = params[:filter].to_s
    @campaign_filter = params[:campaign_id].presence
    base = Current.user.links.order(created_at: :desc).includes(:custom_domain, :campaign)

    @links = @filter == "archived" ? base.archived : base.not_archived
    @links = @links.where(campaign_id: @campaign_filter) if @campaign_filter.present?

    if params[:q].present?
      q = "%#{params[:q].downcase}%"
      @links = @links.where("LOWER(slug) LIKE ? OR LOWER(original_url) LIKE ? OR LOWER(title) LIKE ?", q, q, q)
    end

    counts = Current.user.links
      .group(:archived)
      .select("archived, COUNT(*) AS cnt, COALESCE(SUM(clicks_count), 0) AS total")
      .index_by(&:archived)

    @links_count    = counts[false]&.cnt   || 0
    @total_clicks   = counts[false]&.total || 0
    @archived_count = counts[true]&.cnt    || 0

    # Campaign dropdown data — single query with aggregates
    @campaigns = Current.user.campaigns.with_clicks_count.order(:name)
    @active_campaign = @campaigns.find { |c| c.id.to_s == @campaign_filter.to_s } if @campaign_filter
  end

  def new
    @link = Link.new(campaign_id: params[:campaign_id])
    @campaigns = Current.user.campaigns.order(:name)
  end

  def create
    @link = Current.user.links.build(link_params)

    if @link.save
      PostHog.capture(
        distinct_id: Current.user.posthog_distinct_id,
        event: "link_created",
        properties: {
          slug: @link.slug,
          has_custom_domain: @link.custom_domain_id.present?,
          has_password: @link.password_digest.present?,
          has_expiry: @link.expires_at.present?,
          has_og_image: @link.og_image.attached?,
          has_campaign: @link.campaign_id.present?
        }
      )
      redirect_to links_path, notice: "Link created successfully."
    else
      @campaigns = Current.user.campaigns.order(:name)
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @campaigns = Current.user.campaigns.order(:name)
  end

  def update
    @link.og_image.purge if params.dig(:link, :remove_og_image) == "1"

    if @link.update(link_params.except(:custom_domain_id, :slug))
      PostHog.capture(distinct_id: Current.user.posthog_distinct_id, event: "link_updated", properties: { slug: @link.slug })
      redirect_to links_path, notice: "Link updated."
    else
      @campaigns = Current.user.campaigns.order(:name)
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    PostHog.capture(distinct_id: Current.user.posthog_distinct_id, event: "link_deleted", properties: { slug: @link.slug })
    @link.destroy
    redirect_to links_path, notice: "Link deleted."
  end

  def analytics
    @range = (params[:range] || "30d").to_s
    from = case @range
    when "7d"  then 7.days.ago
    when "90d" then 90.days.ago
    else            30.days.ago
    end

    scoped         = @link.visits.in_range(from, Time.current)
    @total_visits  = @link.clicks_count
    @period_count  = scoped.count
    @clicks_by_day = scoped.group_by_day(:created_at).count
    @top_browsers  = top_n(scoped, :browser, 5)
    @top_countries = top_n(scoped, :country, 10)
    @device_breakdown = scoped.group(:device_type).count
    @top_os        = top_n(scoped, :os, 5)
    @top_referers  = top_n(scoped.where.not(referer: [ nil, "" ]), :referer, 5)
    @recent_visits = @link.visits.recent.limit(20)
  end

  def check_slug
    slug = params[:slug].to_s.strip
    domain_id = params[:custom_domain_id].presence
    taken = slug.present? && Link.not_archived.where(slug: slug, custom_domain_id: domain_id).exists?
    render json: { taken: taken }
  end

  def fetch_og
    url = params[:url].to_s.strip
    return render(json: { error: "No URL" }, status: :unprocessable_entity) if url.blank?

    data = OgFetcherService.new(url).call
    render json: data
  end

  def qr
    PostHog.capture(distinct_id: Current.user.posthog_distinct_id, event: "qr_code_downloaded", properties: { slug: @link.slug })
    require "rqrcode"
    short_url = @link.short_url
    qr = RQRCode::QRCode.new(short_url)
    svg = qr.as_svg(
      color: "000",
      shape_rendering: "crispEdges",
      module_size: 4,
      standalone: true,
      use_path: true
    )
    respond_to do |format|
      format.svg  { render plain: svg, content_type: "image/svg+xml" }
      format.html { render plain: svg, content_type: "image/svg+xml" }
    end
  end

  private

  def top_n(relation, column, n)
    relation.group(column).order("count_all DESC").limit(n).count
  end

  def set_link
    @link = Current.user.links.find(params[:id])
  end

  def link_params
    params.expect(
      link: [
        :original_url, :slug, :title, :description, :og_image,
        :password, :password_confirmation, :expires_at, :max_clicks, :active,
        :custom_domain_id, :campaign_id
      ]
    )
  end
end
