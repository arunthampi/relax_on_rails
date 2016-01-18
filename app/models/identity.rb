class Identity < ActiveRecord::Base
  belongs_to :user
  validates_presence_of :provider, :uid, :token, :team_uid

  def apply_omniauth_hash(hash={})
    self.provider = hash['provider']
    self.uid      = hash['uid']
    self.team_uid = (hash['info'] || {})['team_id']
    self.meta     = hash.to_json

    if credentials_hash = hash['credentials']
      self.token = credentials_hash['token']
      self.secret = credentials_hash['secret']
    end

    self.save
  end
end
