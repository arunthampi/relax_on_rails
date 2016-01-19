class StaticController < ApplicationController
  def index
    current_user.present? ? redirect_to(teams_path) : render(:index)
  end
end
