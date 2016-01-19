callback = Proc.new do |event|
  case event.type
  when 'team.join'
    team = Team.find_by(uid: event.team_uid)
    return if team.nil?
    ImportUsersForTeamJob.perform_async(team.id)

  when 'disable_bot'
    team = Team.find_by(uid: event.team_uid)
    if team.present?
      bot = team.bot

      bot.update_attribute(:enabled, false) if bot.present? && bot.enabled?
    end

  when 'message_new', 'message_changed'
    team = Team.find_by(uid: event.team_uid)
    return if team.nil?

    membership = TeamMembership.where(team_id: team.id, user_uid: event.user_uid).first
    return if membership.nil?

    user = membership.user

    if event.text =~ /hello/im
      reply = ['hi there!', 'aloha', 'namaste!', 'hola'].shuffle.first
    else
      reply = "sorry I couldn't understand what you were saying"
    end

    Slack.new(team.bot.token).call('chat.postMessage', 'POST', channel: event.channel_uid,
                                   text: reply,
                                   as_user: 'true')
  end
end

Relax::EventListener.callback = callback
