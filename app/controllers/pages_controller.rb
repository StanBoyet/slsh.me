class PagesController < ApplicationController
  allow_unauthenticated_access
  layout "landing"

  def landing
  end
end
