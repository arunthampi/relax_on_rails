class Bot < ActiveRecord::Base
  validates_presence_of :team_id, :user_id, :token
  validates_uniqueness_of :token

  belongs_to :team
  belongs_to :creator, foreign_key: :user_id, class_name: 'User'

  def start!
    Relax::Bot.start!(self.team.uid, self.token)
    self.update_attribute(:enabled, true)
  end
end
