class CustomDomainsController < ApplicationController
  # TLS for customer domains is handled by Caddy's on-demand TLS (see
  # config/Caddyfile + config/deploy.yml). Once the user sets a CNAME to
  # the slsh.me server, the first HTTPS request triggers Caddy to ask
  # Let's Encrypt for a cert. There's nothing for Rails to provision.
  def create
    @custom_domain = Current.user.custom_domains.build(custom_domain_params)

    if @custom_domain.save
      redirect_to domains_settings_path,
                  notice: "Domain added. Point a CNAME to slsh.me — the TLS certificate is issued on the first visit."
    else
      @custom_domains = Current.user.custom_domains.order(created_at: :desc)
      render "settings/domains", status: :unprocessable_entity
    end
  end

  def destroy
    domain = Current.user.custom_domains.find(params[:id])
    domain.archive_links!
    domain.destroy

    redirect_to domains_settings_path, notice: "Domain removed. Its links have been archived."
  end

  private

  def custom_domain_params
    params.expect(custom_domain: [ :domain ])
  end
end
