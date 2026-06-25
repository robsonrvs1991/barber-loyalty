class LandingController < ApplicationController
  def index
    if owner?
      redirect_to owner_dashboard_path
    elsif business?
      redirect_to app_dashboard_path
    elsif client_logged_in?
      redirect_to client_portal_path
    end
  end
end