RSpec.describe Laboratory::Algorithms::Random do
  describe '#id' do
    it 'should return RANDOM' do
      expect(described_class.id).to eq('RANDOM')
    end
  end

  describe '#pick!' do
    it 'should return a random selection' do
      srand(11)
      inputs = [
        double('Variant', id: 1, percentage: 50),
        double('Variant', id: 2, percentage: 50)
      ]

      expected_outputs = [1, 2, 2, 2, 1]

      outputs = 5.times.map do
        described_class.pick!(inputs).id
      end

      expect(outputs).to eq(expected_outputs)
    end
  end
end
