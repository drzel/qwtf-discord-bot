class QstatRequest
  attr_accessor :result

  def initialize(endpoint)
    @endpoint = endpoint
  end

  def result
    @result ||= execute
  end

  def to_embed
    return nil if is_empty?

    embed = Discordrb::Webhooks::Embed.new

    teams.each do |team|
      embed.add_field(team.to_embed_field)
    end

    embed
  end

  def to_message
    return server_summary if is_empty?
    [server_summary, player_table].join("\n")
  end

  def server_summary
    return "#{@endpoint} isn't responding" unless game_map
    return "#{name} | #{@endpoint} | #{game_map} | #{numplayers}/#{maxplayers}" unless has_spectators?
    "#{name} | #{@endpoint} | #{game_map} | #{numplayers}/#{maxplayers} players | #{numspectators}/#{maxspectators} spectators"
  end

  def is_empty?
    !has_players? && !has_spectators?
  end

  def player_names
    players.map(&:name)
  end

  def has_players?
    numplayers && numplayers > 0
  end

  private

    def has_spectators?
      numspectators && numspectators > 0
    end

    def teams
      @teams ||= build_roster
    end

    def data
      @data ||= JSON.parse(result).first
    end

    def execute
      %x[qstat -json -P -qws #{@endpoint}]
    end

    def player_table
      players.sort_by { |player| player.team.number }.map(&:to_row).join("\n")
    end

    def name
      data["name"]
    end

    def address
      data["address"]
    end

    def game_map
      data["map"]
    end

    def numplayers
      data["numplayers"]
    end

    def maxplayers
      data["maxplayers"]
    end

    def numspectators
      data["numspectators"]
    end

    def maxspectators
      data["maxspectators"]
    end

    def build_roster
      return nil if is_empty?

      roster = Roster.new

      data["players"].map do |player_data|
        player = Player.new(player_data)
        roster.enroll(player)
      end

      roster.teams.sort_by { |team| team.number }
    end

    def players
      data["players"].map do |player_data|
        Player.new(player_data)
      end
    end
end
