module CrazyEights
  class Implementation < ::GameImplementation
    def initialize(players: [])
      super(players: players)
    end

    def self.from_json(json)
      players = CrazyEights::Player.from_json(json["players"])
      CrazyEights::Implementation.new(players: players)
    end

    def start
    end

    private_class_method :from_json
  end
end
