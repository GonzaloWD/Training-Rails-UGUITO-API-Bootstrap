FactoryBot.define do
  factory :note do
    user
    sequence(:title) { |n| "#{Faker::Lorem.word}#{n}" }
    content { Faker::Lorem.sentence(word_count: rand(20..50)) }
    note_type { Note.note_types.values.sample }

    trait :review do
      note_type { Note.note_types.values[0] }
      content { Faker::Lorem.sentence(word_count: rand(5..50)) }
    end

    trait :critique do
      note_type { Note.note_types.values[1] }
      content { Faker::Lorem.sentence(word_count: rand(20..150)) }
    end
  end
end
