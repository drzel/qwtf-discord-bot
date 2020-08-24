class EventDecorator
  def initialize(event)
    @event = event
  end

  def channel
    @event.channel
  end

  def channel_id
    @event.channel.id
  end

  def username
    user.username
  end

  def user_id
    user.id
  end

  def users
    server.users
  end

  def mentions_for(user_ids)
    find_users(user_ids).map(&:mention)
  end

  def usernames_for(user_ids)
    find_users(user_ids).map(&:username)
  end

  private

  def find_users(user_ids)
    user_ids.map do |user_id|
      find_user(user_id)
    end
  end

  def find_user(user_id)
    users.find { |user| user.id == user_id }
  end

  def server
    @event.server
  end

  def user
    @event.user
  end
end
