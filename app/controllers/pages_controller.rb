class PagesController < ApplicationController
  allow_unauthenticated_access

  def landing
    redirect_to app_url("/links"), allow_other_host: true if authenticated?
  end
end
