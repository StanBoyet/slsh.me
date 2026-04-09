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

    RecordVisitJob.perform_later(
      @link.id,
      request.remote_ip,
      request.user_agent.to_s,
      request.referer.to_s
    )
    @link.increment!(:clicks_count)

    redirect_to @link.original_url, status: :found, allow_other_host: true
  end

  def unlock
    @link = find_link!

    if @link.authenticate_password(params[:password].to_s)
      session["unlocked_link_#{@link.id}"] = true
      RecordVisitJob.perform_later(
        @link.id,
        request.remote_ip,
        request.user_agent.to_s,
        request.referer.to_s
      )
      @link.increment!(:clicks_count)
      redirect_to @link.original_url, status: :found, allow_other_host: true
    else
      flash.now[:alert] = "Incorrect password."
      render :password, status: :unprocessable_entity
    end
  end

  private

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
