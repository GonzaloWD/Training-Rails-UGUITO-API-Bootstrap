shared_examples 'note_content_length_test' do |count, expected|
  context "with words count equal or less than #{count}" do
    let(:content) { 'rep ' * count }

    it "returns #{expected}" do
      expect(subject.content_length).to eq(expected)
    end
  end
end
