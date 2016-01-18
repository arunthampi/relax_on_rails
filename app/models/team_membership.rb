class TeamMembership < ActiveRecord::Base
  validates_presence_of :team_id, :user_id, :membership_type, :user_uid
  validates_inclusion_of :membership_type, in: %w(owner admin guest member deleted)

  belongs_to :team
  belongs_to :user

  def self.membership_type_from_hash(user_hash)
    membership_type = nil

    if user_hash['deleted']
      membership_type = 'deleted'
    elsif user_hash['is_owner']
      membership_type = 'owner'
    elsif user_hash['is_admin']
      membership_type = 'admin'
    elsif user_hash['is_restricted']
      membership_type = 'guest'
    else
      membership_type = 'member'
    end

    membership_type
  end
end
