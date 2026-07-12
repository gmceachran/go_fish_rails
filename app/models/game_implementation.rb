class GameImplementation
  attr_accessor :players

  def initialize(players: [])
    @players = players
  end

  def self.load(json)
    return nil if json.nil?

    from_json(json)
  end

  def self.dump(obj)
    obj.as_json
  end
end
