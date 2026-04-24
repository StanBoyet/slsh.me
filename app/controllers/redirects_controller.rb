class RedirectsController < ApplicationController
  allow_unauthenticated_access

  SOCIAL_BOT_UA = /facebookexternalhit|Twitterbot|LinkedInBot|WhatsApp|Slackbot|Discordbot|
                   Googlebot|bingbot|Applebot|Pinterestbot|Snapchat|TelegramBot|
                   vkShare|W3C_Validator|ia_archiver/xi.freeze

  def show
    @link = find_link!

    unless @link.active?
      return render :gone, status: :gone
    end

    if @link.expired?
      @link.update_column(:active, false) if @link.active?
      return render :gone, status: :gone
    end

    if social_bot?
      return render :og_preview, layout: false
    end

    if @link.password_protected? && !session_unlocked?(@link)
      return render :password, status: :ok
    end

    track_and_redirect!
  end

  def unlock
    @link = find_link!

    if @link.authenticate_password(params[:password].to_s)
      session["unlocked_link_#{@link.id}"] = true
      PostHog.capture(
        distinct_id: @link.user.posthog_distinct_id,
        event: "link_password_unlocked",
        properties: { slug: @link.slug }
      )
      track_and_redirect!
    else
      flash.now[:alert] = "Incorrect password."
      render :password, status: :unprocessable_entity
    end
  end

  private

  def track_and_redirect!
    real_ip = request.headers["CF-Connecting-IP"].presence || request.remote_ip
    RecordVisitJob.perform_later(@link.id, real_ip, request.user_agent.to_s, request.referer.to_s)
    PostHog.capture(
      distinct_id: @link.user.posthog_distinct_id,
      event: "link_clicked",
      properties: { slug: @link.slug, custom_domain: custom_domain_request? }
    )
    @link.increment!(:clicks_count)
    redirect_to @link.original_url, status: :found, allow_other_host: true
  end

  def find_link!
    if custom_domain_request?
      domain = CustomDomain.find_by!(domain: request.host)
      domain.links.find_by!(slug: params[:slug])
    else
      Link.where(custom_domain_id: nil).find_by!(slug: params[:slug])
    end
  end

  def social_bot?
    request.user_agent.to_s.match?(SOCIAL_BOT_UA)
  end

  def session_unlocked?(link)
    session["unlocked_link_#{link.id}"] == true
  end
end
