class LinksController < ApplicationController
  before_action :set_link, only: %i[edit update destroy analytics qr]

  def index
    @links = Current.user.links
                    .order(created_at: :desc)
                    .includes(:visits)

    if params[:q].present?
      q = "%#{params[:q].downcase}%"
      @links = @links.where("LOWER(slug) LIKE ? OR LOWER(original_url) LIKE ? OR LOWER(title) LIKE ?", q, q, q)
    end

    @total_clicks = Current.user.links.sum(:clicks_count)
    @links_count  = Current.user.links.count
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
    if @link.update(link_params)
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

    @visits        = @link.visits.human.in_range(from, Time.current)
    @total_visits  = @link.visits.human.count
    @clicks_by_day = @visits.group_by_day(:created_at).count
    @top_browsers  = top_n(@visits, :browser, 6)
    @top_countries = top_n(@visits, :country, 10)
    @device_breakdown = @visits.group(:device_type).count
    @top_os        = top_n(@visits, :os, 6)
    @top_referers  = top_n(@visits.where.not(referer: [ nil, "" ]), :referer, 5)
    @recent_visits = @link.visits.human.recent.limit(20)
  end

  def check_slug
    slug  = params[:slug].to_s.strip
    taken = slug.present? && Link.exists?(slug: slug)
    render json: { taken: taken }
  end

  def qr
    require "rqrcode"
    short_url = redirect_url(@link.slug)
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
    relation.group(column).count.sort_by { |_, v| -v }.first(n).to_h
  end

  def set_link
    @link = Current.user.links.find(params[:id])
  end

  def link_params
    params.expect(
      link: [
        :original_url, :slug, :title, :description, :og_image_url,
        :password, :password_confirmation, :expires_at, :max_clicks, :active
      ]
    )
  end
end
