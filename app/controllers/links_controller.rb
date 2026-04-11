class LinksController < ApplicationController
  before_action :set_link, only: %i[edit update destroy analytics qr]

  def index
    @filter = params[:filter].to_s
    base = Current.user.links.order(created_at: :desc).includes(:custom_domain)

    @links = @filter == "archived" ? base.archived : base.not_archived

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
  end

  def new
    @link = Link.new
  end

  def create
    @link = Current.user.links.build(link_params)

    if @link.save
      redirect_to links_path, notice: "Link created successfully."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @link.update(link_params.except(:custom_domain_id, :slug))
      redirect_to links_path, notice: "Link updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
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

  def qr
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
        :original_url, :slug, :title, :description, :og_image_url,
        :password, :password_confirmation, :expires_at, :max_clicks, :active,
        :custom_domain_id
      ]
    )
  end
end
