FactoryBot.define do
  factory :game do
    max_players { 5 }

    trait :with_players do
      after(:create) do |model, evaluator|
        create(:player, game: model)
        create(:player, game: model)
      end
    end
  end
end
