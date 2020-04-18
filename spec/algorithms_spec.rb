RSpec.describe Laboratory::Algorithms do
  describe '#to_class' do
    context 'when a valid identifier is passed in' do
      it 'should return the associated class' do
        expect(described_class.to_class(Laboratory::Algorithms::Random.id))
          .to eq(Laboratory::Algorithms::Random)
      end
    end

    context 'when an invalid identifier is passed in' do
      it 'should return nil' do
        expect(described_class.to_class('nonsense')).to be nil
      end
    end
  end
end
