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
    subject(:note) { create(:note, content: content) }

    context 'with generic input' do
      let(:content) { 'Esto es una prueba de siete palabras' }

      it 'returns the number of words' do
        expect(subject.word_count).to eq(7)
      end
    end

    context 'with punctuation marks and spaces' do
      let(:content) { '¡Hola, hermoso mundo! Tiene seis palabras.' }

      it 'returns correct number of words' do
        expect(subject.word_count).to eq(6)
      end
    end

    context 'with numbers and words' do
      let(:content) { '12345 prueba de 4 numeros' }

      it 'returns the number of words' do
        expect(subject.word_count).to eq(5)
      end
    end
  end

  describe '#content_length' do
    context 'with north utility' do
      subject(:note) { create(:note, user: user, content: content, note_type: :critique) }

      let(:user) { create(:user, utility: north_utility) }

      include_examples 'note_content_length_test', 50, 'short'

      include_examples 'note_content_length_test', 100, 'medium'

      include_examples 'note_content_length_test', 120, 'long'
    end

    context 'with south utility' do
      subject(:note) { create(:note, user: user, content: content, note_type: :critique) }

      let(:user) { create(:user, utility: south_utility) }

      include_examples 'note_content_length_test', 60, 'short'

      include_examples 'note_content_length_test', 120, 'medium'

      include_examples 'note_content_length_test', 130, 'long'
    end
  end

  describe '#save!' do
    context 'with type review' do
      subject(:note_type_review) do
        build(:note, :review, user: user, content: content)
      end

      let(:user) { create(:user, utility: south_utility) }

      context 'when has valid content length' do
        let(:content) { 'rep ' * 30 }

        it 'create note succesfully' do
          expect(subject.save!).to be_truthy
        end
      end

      context 'when has invalid content length' do
        let(:content) { 'rep ' * 70 }

        it 'returns ActiveRecord::RecordInvalid' do
          expect { subject.save! }.to raise_error(ActiveRecord::RecordInvalid)
        end
      end
    end
  end
end
