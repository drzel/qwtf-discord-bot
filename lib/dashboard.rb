class Dashboard
  def initialize(channel, bot)
    @channel_id = channel["id"]
    @endpoints = channel["endpoints"]
    @bot = bot
    @messages = {}
  end

  def update
    @endpoints.each do |endpoint|
      qstat_request = QstatRequest.new(endpoint)

      if qstat_request.is_empty?
        next unless @messages[endpoint]

        @messages[endpoint].delete
        @messages.delete(endpoint)
      end

      embed = qstat_request.to_full_embed

      @messages[endpoint] = if @messages[endpoint]
                              @messages[endpoint].edit(nil, embed)
                            else
                              channel.send_embed(nil, embed)
                            end
    end
  end

  private

  def channel
    data = Discordrb::API::Channel.resolve(
      "Bot #{QwtfDiscordBot.config.token}",
      @channel_id
    )

    Discordrb::Channel.new(JSON.parse(data), @bot)
  end
end