class SettingsController < ApplicationController
  def profile
  end

  def update_profile
    if Current.user.update(profile_params)
      redirect_to profile_settings_path, notice: "Profile updated."
    else
      render :profile, status: :unprocessable_entity
    end
  end

  def domains
    @custom_domain = Current.user.custom_domains.new
    @custom_domains = Current.user.custom_domains.order(created_at: :desc)
  end

  private

  def profile_params
    params.expect(user: [ :username, :avatar ])
  end
end
