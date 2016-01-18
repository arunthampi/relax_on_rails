class Team < ActiveRecord::Base
  has_many :team_memberships
  has_many :members, through: :team_memberships, source: :user
  has_one  :bot

  validates_presence_of :name, :uid, :url
  validates_uniqueness_of :uid

  validates_url :url, no_local: true, allow_nil: true

  def import_users!
    return if bot.blank?

    slack_client = Slack.new(bot.token)
    json_list = slack_client.call('users.list', :get)

    if json_list['ok'] == true
      Team.with_advisory_lock("team-import-#{self.uid}") do
        json_list['members'].each do |user|
          new_record = false

          if(existing_membership = self.team_memberships.find_by_user_uid(user['id'])).blank?
            u = User.new
            new_record = true
          else
            u = existing_membership.user
          end

          u.nickname = user['name']
          if u.email.blank?
            u.email = user['profile']['email']
          end

          u.first_name = user['profile']['first_name']
          u.last_name = user['profile']['last_name']
          u.full_name = user['profile']['real_name']

          u.timezone = user['tz']
          u.timezone_description = user['tz_label']
          u.timezone_offset = user['tz_offset'].to_i
          u.save!

          membership_type = TeamMembership.membership_type_from_hash(user)

          if existing_membership.present?
            existing_membership.update_attribute(:membership_type, membership_type)
          else
            TeamMembership.create!(user: u, team: self, membership_type: membership_type, user_uid: user['id'])
          end
        end
      end
    end
  end
end
