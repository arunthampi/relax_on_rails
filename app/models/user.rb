class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable,
         :omniauthable

  has_many :team_memberships
  has_many :teams, through: :team_memberships
  has_many :identities

  def update_omniauth_identity(data)
    identity = self.identities.where(provider: data['provider'], uid: data['uid']).first

    if identity.nil? || identity.team_uid != data['info']['team_id']
      identity = Identity.new
      identity.user = self
    end

    identity.apply_omniauth_hash(data)
    identity.save!

    self.update_from_omniauth_hash(data)
  end

  def update_from_omniauth_hash(data, profile_params = {})
    self.email    = data['info']['email'] if self.email.blank?
    self.full_name = data['info']['name']
    self.first_name = data['info']['first_name']
    self.last_name = data['info']['last_name']
    self.nickname = data['info']['nickname']
    self.signed_in_via_oauth = true

    self.image_url = data['info']['image']
    self.timezone = data['extra']['user_info']['user']['tz']
    self.timezone_description = data['extra']['user_info']['user']['tz_label']
    self.timezone_offset = data['extra']['user_info']['user']['tz_offset']

    profile_params.each do |param, value|
      self.send("#{param}=", value) if self.respond_to?("#{param}=")
    end

    self.save!

    raw_info = data['extra']['raw_info']

    unless(team = Team.find_by_uid(raw_info['team_id']))
      team = Team.create!(uid: raw_info['team_id'],
                          name: raw_info['team'],
                          url: raw_info['url'])

    end

    user_hash = data['extra']['user_info']['user']

    if (tm = TeamMembership.where(team: team, user: self).first).present?
      tm.update_attribute(:membership_type, TeamMembership.membership_type_from_hash(user_hash))
    else
      membership_type = TeamMembership.membership_type_from_hash(user_hash)
      TeamMembership.create!(user: self, team: team, membership_type: membership_type, user_uid: data['uid'])
    end

    self
  end

  # Given data comes back from omniauth hash
  # create a new user with identity and a random password
  # `username` can be empty here. We expect the user to fill in username before
  # he can login to the site
  def self.create_from_omniauth_data(data, profile_params = {})
    user = User.new
    identity = Identity.new
    identity.apply_omniauth_hash(data)
    user.identities << identity

    user.update_from_omniauth_hash(data, profile_params)
  end
end
