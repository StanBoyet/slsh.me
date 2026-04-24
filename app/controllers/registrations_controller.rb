class RegistrationsController < ApplicationController
  allow_unauthenticated_access

  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)
    if @user.save
      start_new_session_for(@user)

      PostHog.identify(distinct_id: @user.posthog_distinct_id, properties: @user.posthog_properties)
      PostHog.capture(distinct_id: @user.posthog_distinct_id, event: "user_signed_up", properties: { signup_method: "form" })

      redirect_to root_path, notice: "Welcome! Your account has been created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  private

  def user_params
    params.expect(user: [ :username, :email_address, :password, :password_confirmation ])
  end
end
