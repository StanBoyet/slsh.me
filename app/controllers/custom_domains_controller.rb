class CustomDomainsController < ApplicationController
  def create
    @custom_domain = Current.user.custom_domains.build(custom_domain_params)

    if @custom_domain.save
      result = fly_certs.add(@custom_domain.domain)
      if result.success?
        redirect_to domains_settings_path, notice: "Domain added and certificate requested. Set a CNAME record pointing to slsh-me.fly.dev."
      else
        redirect_to domains_settings_path, notice: "Domain added. Certificate provisioning failed (#{result.error || "status #{result.status}"}) — set a CNAME to slsh-me.fly.dev and it will retry automatically."
      end
    else
      @custom_domains = Current.user.custom_domains.order(created_at: :desc)
      render "settings/domains", status: :unprocessable_entity
    end
  end

  def check
    domain = Current.user.custom_domains.find(params[:id])
    result = fly_certs.check(domain.domain)

    if result.success?
      configured = result.body&.dig("configured")
      domain.update!(verified: configured) if configured == true || configured == false

      if configured
        redirect_to domains_settings_path, notice: "#{domain.domain} is verified and active."
      else
        redirect_to domains_settings_path, alert: "#{domain.domain} is not yet configured. Make sure your CNAME points to slsh-me.fly.dev."
      end
    else
      redirect_to domains_settings_path, alert: "Could not check #{domain.domain}: #{result.error || "status #{result.status}"}."
    end
  end

  def destroy
    domain = Current.user.custom_domains.find(params[:id])
    hostname = domain.domain
    domain.archive_links!
    domain.destroy

    fly_certs.delete(hostname)

    redirect_to domains_settings_path, notice: "Domain removed. Its links have been archived."
  end

  private

  def custom_domain_params
    params.expect(custom_domain: [ :domain ])
  end

  def fly_certs
    @fly_certs ||= FlyCertificatesService.new
  end
end
