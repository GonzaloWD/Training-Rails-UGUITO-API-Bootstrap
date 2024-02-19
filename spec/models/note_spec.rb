require 'rails_helper'

RSpec.describe Note, type: :model do
  subject(:note) do
    create(:note)
  end

  %i[user_id note_type content title].each do |value|
    it { is_expected.to validate_presence_of(value) }
  end

  it 'has a valid factory' do
    expect(subject).to be_valid
  end
end
