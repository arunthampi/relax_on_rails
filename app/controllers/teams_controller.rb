class TeamsController < ApplicationController
  before_filter :authenticate_user!

  def index
    @teams = current_user.teams
  end

  def show
    @team = current_user.teams.find_by_uid(params[:id])
    raise ActiveRecord::RecordNotFound if @team.blank?
  end
end
