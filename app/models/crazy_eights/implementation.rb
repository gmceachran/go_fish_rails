module CrazyEights
  class Implementation < ::GameImplementation
    # ASK: file structure for abstracting a lot of this stuff
    # into a game superclass while navigating namespacing

    def self.from_json(json)
      players = CrazyEights::Player.from_json(json["players"])
      CrazyEights::Implementation.new(players: players)
    end

    def start
    end

    private_class_method :from_json
  end
end
