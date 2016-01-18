class OmniauthCallbacksController < Devise::OmniauthCallbacksController
  def failure
    redirect_to teams_path
  end

  def slack
    redirect_to root_path and return unless omniauth_hash

    provider = omniauth_hash['provider']
    referral_code = (request.env['omniauth.params'] || {})['referral_code']

    if (user = authenticating_user)
      user.update_omniauth_identity(omniauth_hash)
      team = user.teams.find_by(uid: omniauth_hash['info']['team_id'])
      setup_bot_for(team, user)

      redirect_path = team_path(omniauth_hash['info']['team_id'])
    else
      user = User.create_from_omniauth_data(omniauth_hash, referral_code: referral_code)

      if user.persisted?
        team = user.teams.find_by(uid: omniauth_hash['info']['team_id'])
        setup_bot_for(team, user)

        redirect_path = team_path(team.uid)
      else
        flash[:notice] = "Cannot create new account. Please try again"
        redirect_path = root_path
      end
    end

    sign_in user if user.persisted?

    redirect_to redirect_path
  end

  protected
  def setup_bot_for(team, user)
    if (bot = team.bot).blank? && (bot_info = omniauth_hash['extra']['bot_info']).present?
      bot = team.build_bot
      bot.creator = user
      bot.token = bot_info['bot_access_token']
      bot.save! && bot.start!

      ImportUsersForTeamJob.perform_async(team.id)
    end
  end

  def omniauth_hash
    @omniauth_hash ||= request.env['omniauth.auth']
    @omniauth_hash
  end

  def authenticating_user
    @authenticating_user = current_user

    if !@authenticating_user
      @authenticating_user = current_identity.try(:user)
      if !@authenticating_user
        team_uid = omniauth_hash['info']['team_id']
        team = Team.find_by_uid(team_uid)
        if team.present?
          membership = team.team_memberships.find_by_user_uid(omniauth_hash['uid'])
          @authenticating_user = membership.try(:user)
        end
      end
    end

    @authenticating_user
  end

  # find the current identity if possible via provided provider and
  # uid of omniauth_hash
  #
  # Returns an instance of `identity` or nil when the user doesnt have any
  # existing identity
  def current_identity
    @current_identity ||= Identity.
      where(provider: omniauth_hash['provider'], uid: omniauth_hash['uid']).
      first
  end
end
