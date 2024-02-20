FactoryBot.define do
  factory :note do
    user
    sequence(:title) { |n| "#{Faker::Lorem.word}#{n}" }
    content { Faker::Lorem.paragraph }
    note_type { Note.note_types.values.sample }
  end
end
