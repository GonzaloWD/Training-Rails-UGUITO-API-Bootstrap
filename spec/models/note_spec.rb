require 'rails_helper'

RSpec.describe Note, type: :model do
  subject(:note) do
    create(:note)
  end

  %i[user_id note_type content title].each do |value|
    it { is_expected.to validate_presence_of(value) }
  end

  it { is_expected.to belong_to(:user) }

  it { is_expected.to have_one(:utility).through(:user) }

  it 'has a valid factory' do
    expect(subject).to be_valid
  end

  describe '#word_count' do
    it 'returns the number of words in the content' do
      subject.content = 'Esto es una prueba de siete palabras'
      expect(subject.word_count).to eq(7)
    end

    it 'correctly handles punctuation marks and spaces' do
      subject.content = '¡Hola, hermoso mundo! Tiene seis palabras.'
      expect(subject.word_count).to eq(6)
    end

    it 'handle numbers and words' do
      subject.content = '12345 prueba de 4 numeros'
      expect(subject.word_count).to eq(5)
    end

    it 'correctly handles empty content' do
      subject.content = ''
      expect(subject.word_count).to eq(0)
    end
  end

  describe '#content_length with north utility' do
    before do
      subject.utility = NorthUtility.new
    end

    it 'returns short for content words count equal or less than 50' do
      subject.content = 'rep ' * 50
      expect(subject.content_length).to eq('short')
    end

    it 'returns medium for content words count  equal or less than 100' do
      subject.content = 'rep ' * 100
      expect(subject.content_length).to eq('medium')
    end

    it 'returns long for content words count greater than 100' do
      subject.content = 'rep ' * 120
      expect(subject.content_length).to eq('long')
    end
  end

  describe '#content_length with south utility' do
    before do
      subject.utility = SouthUtility.new
    end

    it 'returns short for content words count equal or less than 50' do
      subject.content = 'rep ' * 60
      expect(subject.content_length).to eq('short')
    end

    it 'returns medium for content words count  equal or less than 100' do
      subject.content = 'rep ' * 120
      expect(subject.content_length).to eq('medium')
    end

    it 'returns long for content words count greater than 100' do
      subject.content = 'rep ' * 130
      expect(subject.content_length).to eq('long')
    end
  end

  describe '#valid_content_count? for type review' do
    subject(:note_type_review) do
      FactoryBot.create(:note, :review)
    end

    it 'returns false if review word_count greater than 60' do
      subject.content = subject.content = 'rep ' * 70
      expect(subject.valid_content_count?).to eq(false)
    end

    it 'returns true if review word_count equal or less than 60' do
      subject.content = subject.content = 'rep ' * 40
      expect(subject.valid_content_count?).to eq(true)
    end
  end

  describe '#valid_content_count? for type critique' do
    subject(:note_type_critique) do
      FactoryBot.create(:note, :critique)
    end

    it 'returns true if critique word_count greater than 60' do
      subject.content = subject.content = 'rep ' * 70
      expect(subject.valid_content_count?).to eq(true)
    end

    it 'returns true if review word_count equal or less 60' do
      subject.content = subject.content = 'rep ' * 40
      expect(subject.valid_content_count?).to eq(true)
    end
  end
end
