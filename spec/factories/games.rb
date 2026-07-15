FactoryBot.define do
  factory :game do
    max_players { 5 }
    type { "GoFishGame" }

    initialize_with { type.present? ? type.constantize.new(attributes) : Game.new(attributes) }

    trait :with_players do
      after(:create) do |model, evaluator|
        create(:player, game: model)
        create(:player, game: model)
      end
    end

    trait :finished do
      max_players { 1 }

      after(:create) do |model, evaluator|
        player = create(:player, game: model)
        model.declare_winner!(player)
      end
    end
  end
end
