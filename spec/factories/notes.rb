FactoryBot.define do
  factory :note do
    user
    sequence(:title) { |n| "#{Faker::Lorem.word}#{n}" }
    content { Faker::Lorem.paragraph }
    note_type { Note::TYPES_ATTRIBUTES.sample }
  end
end
