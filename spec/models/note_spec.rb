require 'rails_helper'

RSpec.describe Note, type: :model do
  subject(:note) do
    create(:note)
  end

  let(:north_utility) { create(:north_utility, code: 1) }
  let(:south_utility) { create(:south_utility, code: 2) }

  %i[note_type content title].each do |value|
    it { is_expected.to validate_presence_of(value) }
  end

  it { is_expected.to have_one(:utility).through(:user) }

  it 'has a valid factory' do
    expect(subject).to be_valid
  end

  describe '#word_count' do
    context 'with generic input' do
      it 'returns the number of words' do
        subject.content = 'Esto es una prueba de siete palabras'
        expect(subject.word_count).to eq(7)
      end
    end

    context 'with punctuation marks and spaces' do
      it 'returns correct number of words' do
        subject.content = '¡Hola, hermoso mundo! Tiene seis palabras.'
        expect(subject.word_count).to eq(6)
      end
    end

    context 'with numbers and words' do
      it 'returns the number of words' do
        subject.content = '12345 prueba de 4 numeros'
        expect(subject.word_count).to eq(5)
      end
    end

    context 'with empty content' do
      it 'return 0' do
        subject.content = ''
        expect(subject.word_count).to eq(0)
      end
    end
  end

  describe '#content_length' do
    context 'with north utility' do
      subject(:note) { create(:note, user: user, content: content, note_type: :critique) }

      let(:user) { create(:user, utility: north_utility) }

      context 'with words count equal or less than 50' do
        let(:content) { 'rep ' * 50 }

        it 'returns short' do
          expect(subject.content_length).to eq('short')
        end
      end

      context 'with content words count equal or less than 100' do
        let(:content) { 'rep ' * 100 }

        it 'returns medium' do
          expect(subject.content_length).to eq('medium')
        end
      end

      context 'with content words count greater than 100' do
        let(:content) { 'rep ' * 120 }

        it 'returns long' do
          expect(subject.content_length).to eq('long')
        end
      end
    end

    context 'with south utility' do
      subject(:note) { create(:note, user: user, content: content, note_type: :critique) }

      let(:user) { create(:user, utility: south_utility) }

      context 'with words count equal or less than 60' do
        let(:content) { 'rep ' * 60 }

        it 'returns short' do
          expect(subject.content_length).to eq('short')
        end
      end

      context 'with content words count equal or less than 120' do
        let(:content) { 'rep ' * 120 }

        it 'returns medium' do
          expect(subject.content_length).to eq('medium')
        end
      end

      context 'with content words count greater than 120' do
        let(:content) { 'rep ' * 130 }

        it 'returns long' do
          expect(subject.content_length).to eq('long')
        end
      end
    end
  end

  describe '#save!' do
    context 'with type review' do
      subject(:note_type_review) do
        FactoryBot.build(:note, :review, user: user, content: content)
      end

      let(:user) { create(:user, utility: south_utility) }

      context 'when review word_count greater than 60' do
        let(:content) { 'rep ' * 70 }

        it 'returns false' do
          expect { subject.save! }.to raise_error(ActiveRecord::RecordInvalid)
        end
      end
    end
  end
end
