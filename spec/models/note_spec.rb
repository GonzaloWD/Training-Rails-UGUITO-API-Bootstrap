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
end
