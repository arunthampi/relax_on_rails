class ImportUsersForTeamJob
  include Sidekiq::Worker

  def perform(team_id)
    team = Team.find(team_id)
    team.import_users!
  end
end

