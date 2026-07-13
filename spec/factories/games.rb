FactoryBot.define do
  factory :game, class: "GoFishGame" do
    max_players { 5 }

    trait :with_players do
      after(:create) do |model, evaluator|
        create(:player, game: model)
        create(:player, game: model)
      end
    end

    factory :crazy_eights_game, class: "CrazyEightsGame"

    # trait :finished do
    #   max_players { 1 }
    #   after(:create) do |model, evaluator|
    #     create(:player, game: model, winner: true)
    #   end

    #   ended_at { Time.current }
    #   state { :over }
    # end
  end
end
